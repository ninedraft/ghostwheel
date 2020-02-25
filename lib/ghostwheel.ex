defmodule Ghostwheel do
  @moduledoc """
  Documentation for Ghostwheel.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Ghostwheel.hello()
      :world

  """
  def hello do
    :world
  end

  def days_until(day_x, loc) do
    x = Date.from_erl(day_x)

    DateTime.now("Etc/UTC", Tzdata.TimeZoneDatabase)
    |> case do
      {:ok, date} -> date
    end
    |> DateTime.to_date()
    |> Date.diff(x)
  end
end

defmodule Ghostwheel.App do
  use Application
  import Logger

  def start(type, args) do
    Logger.debug("Running GhostWheel: #{inspect(type)} #{inspect(args, limit: 8)} ")
    {:ok, self()}
  end
end
