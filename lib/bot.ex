defmodule Ghostwheel.Bot do
  @max_poll_interval 10 * 1000
  @admin_user_id Application.compile_env!(:ghostwheel, :admin_user_id)

  use Task
  require Logger

  @spec start_link(any) :: {:ok, pid}
  def start_link(_) do
    Task.start_link(__MODULE__, :run, [])
  end

  @spec run(integer(), integer()) :: no_return
  def run(offset \\ 0, poll_interval \\ 1000) do
    case Nadia.get_updates(offset: offset) do
      {:ok, updates} when updates != [] ->
        Logger.debug("got #{length(updates)} updates")
        %{update_id: last_update_id} = List.last(updates)
        Enum.each(updates, &proccess_update/1)
        run(last_update_id + 1)

      _ ->
        Logger.info("sleeping #{poll_interval / 1000}s")
        Process.sleep(poll_interval)
        next_poll_interval = min(@max_poll_interval, 2 * poll_interval)
        run(offset, next_poll_interval)
    end
  end

  @spec proccess_update(Nadia.Model.Update) :: any
  defp proccess_update(upd) do
    case upd do
      %{:message => message} ->
        digest = String.slice(message.text, 0..16)
        Logger.debug("message from @#{message.from.username}: #{digest}")
        route_command(message)

      _ ->
        Logger.debug("update #{upd.update_id} #{Map.keys(upd)}")
        :ok
    end
  end

  defp route_command(message) do
    cond do
      is_command(message.text, "report") and message.from.id == @admin_user_id ->
        send_report(message.chat.id)

      true ->
        nil
    end
  end

  @spec send_report(integer) :: :ok
  def send_report(to \\ @admin_user_id) do
    send_weather(to)
    send_exchange_rates(to)
    send_today_tasks(to)
    :ok
  end

  defp send_weather(to) do
    import Ghostwheel.Weather

    card = "#погода\n\n```\n" <> weather() <> "\n```"
    Nadia.send_message(to, card, parse_mode: "Markdown")
  end

  defp send_today_tasks(to) do
    import Ghostwheel.Todoist

    tasks = today()
    list = "#задачи\n\n" <> tasks_markdown_list(tasks)
    Nadia.send_message(to, list, parse_mode: "Markdown")
  end

  defp send_exchange_rates(to) do
    import Ghostwheel.Exchange
    report = today()
    md = "#валюты\n\n```\n" <> format(report) <> "\n```"
    Nadia.send_message(to, md, parse_mode: "Markdown")
  end

  defp is_command(text, command) do
    text
    |> String.trim_leading()
    |> String.trim_leading("/")
    |> String.starts_with?(command)
  end
end
