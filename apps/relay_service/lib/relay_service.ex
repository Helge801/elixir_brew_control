defmodule RelayService do

  use GenServer

  alias Circuits.GPIO

  @gpios Application.get_env(:relay_service, :relay_GPIOs)
  @gpio_high 1
  @gpio_low 0

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    IO.inspect("#{__MODULE__}.init")
    {:ok, setup_gpios()}
  end

  defp setup_gpios() do
    setter = fn {relay, gpio} ->
      IO.inspect("#{__MODULE__}: Setting up GPIO #{gpio} for #{relay} relay")
      {:ok, gpio} = GPIO.open(gpio, :output)
      {relay, gpio}
    end

    @gpios
    |> Enum.map(setter)
  end

  def handle_cast({:set_relay, relay, relay_state}, state) do
    set_relay(relay, relay_state, state)
    {:noreply, state}
  end

  defp set_relay(relay, relay_state, state) when is_atom(relay) do
    IO.inspect("#{__MODULE__}.set_relay: setting #{relay} to #{relay_state}")
    set_gpio(state[relay], relay_state)
  end

  defp set_relay(_, _, _), do: IO.inspect("#{__MODULE__}.set_relay: relay must be an atom")

  defp set_gpio(nil, _), do: IO.inspect("#{__MODULE__}.set_gpio: relay not found")
  defp set_gpio(gpio, 1), do: GPIO.write(gpio, @gpio_high)
  defp set_gpio(gpio, _), do: GPIO.write(gpio, @gpio_low) # For safety, any gpio state that is not @gpio_high is set low, including invalid states

end
