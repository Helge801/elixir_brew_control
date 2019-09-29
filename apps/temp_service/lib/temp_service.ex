defmodule TempService do
  @moduledoc """
  Documentation for TempService.
  """
  require Logger

  @device_directory "/sys/bus/w1/devices/"
  @slave_location "/w1_slave"
  @sensors Application.get_env(:temp_service, :sensors)

  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    Logger.info("#{__MODULE__}.init")
    initial_state =
      @sensors
        |> Enum.map(&build_path/1)

    {:ok, initial_state}
  end

  defp build_path({key, value}) do
    path =
      @device_directory <> value <> @slave_location
      |> Path.expand

    {key, path}
  end

  def get_state(), do: GenServer.call(__MODULE__, :get_state)
  def read_temps(), do: GenServer.call(__MODULE__, :read_temps)

  def handle_call(:read_temps, _from, state) do
    {:reply, get_temps(state), state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  defp get_temps(sensors) do
    Enum.map(sensors, fn {sensor, path} ->
      temp = 
        path
        |> read_from_sensor
        |> capture_temp
        |> extract_temp
        |> convert_temp

      {sensor, temp}
    end)
  end

  defp read_from_sensor(path) do
    case File.read(path) do
      {:ok, content} -> content
      {:error, reason} -> {:error, "Failed to read temp: #{inspect(reason)}"}
    end 
  end

  defp convert_temp({:error,_} = temp), do: temp

  defp convert_temp(temp) do
    case Float.parse(temp) do
      {converted, _ } -> ((converted / 1000) * 1.8) + 32 |> Float.round(1)
        :error -> {:error, "Could not convert #{inspect(temp)} to float"}
    end
  end


  defp capture_temp({:error, _} = temp), do: temp
  defp capture_temp(temp), do: Regex.run(~r/t=(\d+)/, inspect(temp))
  defp extract_temp({:error, _} = capture), do: capture
  defp extract_temp([_, temp]), do: temp

end
