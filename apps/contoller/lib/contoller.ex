defmodule Contoller do
  @moduledoc """
  Documentation for Contoller.
  """

  use GenServer

  require Logger

  def start_link(state \\ []) do
    Logger.info("#{__MODULE__}.start_link: #{inspect(state)}")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    initial_state = %{
      fermentor_1_target: Application.get_env(:controller, :fermentor_1_target),
      fermentor_2_target: Application.get_env(:controller, :fermentor_2_target, 70),
      fermentor_lower_tolerance: Application.get_env(:controller, :fermentor_lower_tolerance),
      fermentor_upper_tolerance: Application.get_env(:controller, :fermentor_upper_tolerance),
      internal_upper_tolerance: Application.get_env(:controller, :internal_upper_tolerance),
      internal_lower_tolerance: Application.get_env(:controller, :internal_lower_tolerance),
      internal_offset: Application.get_env(:controller, :internal_offset)
    }

    {:ok, initial_state}
  end

  def handle_cast({:update_setting, setting, setting_state}, _from, state) do
    new_state = update_setting(setting, setting_state, state)
    {:no_reply, new_state}
  end

  def handle_cast(:step, _from, state) do
    step(state)
    {:no_reply, state}
  end

  defp update_setting(setting, setting_state, state)
       when is_integer(setting_state) and is_atom(setting) do
    state
    |> Map.has_key?(setting)
    |> case do
      false -> state
      true -> Map.put(state, setting, setting_state)
    end
  end

  defp update_setting(_, _, state), do: state

  defp step(_state) do
    TempService
    |> GenServer.call(:read_temps)
    |> IO.inspect()
  end
end
