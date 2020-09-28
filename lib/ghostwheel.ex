defmodule Ghostwheel.Application do
  use Application

  @spec start(any, any) :: {:ok, pid}
  def start(_type, _args) do
    children = [
      Ghostwheel.Sheduler,
      Ghostwheel.Bot
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: Ghostwheel.Supervisor
    )
  end
end
