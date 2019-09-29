defmodule RelayService do
  use GenServer
  require Logger
  alias Circuits.GPIO

  @gpios Application.get_env(:relay_service, :relay_GPIOs)
  @gpio_high 1
  @gpio_low 0

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(_) do
    Logger.info("#{__MODULE__}.init")
    Process.flag(:trap_exit, true)
    {:ok, setup_gpios()}
  end

  defp setup_gpios() do
    setter = fn {relay, gpio} ->
      Logger.info("#{__MODULE__}: Setting up GPIO #{gpio} for #{relay} relay")
      {:ok, gpio} = GPIO.open(gpio, :output)
      {relay, gpio}
    end

    @gpios
    |> Enum.map(setter)
  end

  def handle_cast({:set_relay, relay, relay_state}, _from, state) do
    set_relay(relay, relay_state, state)
    {:no_reply, state}
  end

  defp set_relay(relay, relay_state, state) when is_atom(relay) do
    Logger.info("#{__MODULE__}.set_relay: setting #{relay} to #{relay_state}")
    set_gpio(state[relay], relay_state)
  end

  defp set_relay(_, _, _), do: Logger.warn("#{__MODULE__}.set_relay: relay must be an atom")

  defp set_gpio(nil, _), do: Logger.warn("#{__MODULE__}.set_gpio: relay not found")
  defp set_gpio(gpio, 1), do: GPIO.write(gpio, @gpio_high)
  defp set_gpio(gpio, _), do: GPIO.write(gpio, @gpio_low) # For safety, any gpio state that is not @gpio_high is set low, including invalid states

  def terminate(reason, state) do
    Logger.warn("#{__MODULE__}.terminate: #{inspect(reason)}")

    state
    |> Enum.map(fn {_, gpio} ->
      GPIO.write(gpio, 0)
    end)

    {:EXIT, reason}
  end
end
