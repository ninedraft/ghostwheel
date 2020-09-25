defmodule Ghostwheel do
  @max_poll_interval 5000
  @admin_user_id 38_625_843

  @moduledoc """
  Documentation for `Ghostwheel`.
  """

  def run(offset \\ 0, poll_interval \\ 1000) do
    default_update = [%{update_id: offset}]
    {:ok, updates} = Nadia.get_updates(offset: offset)
    %{update_id: last_update_id} = List.last(default_update ++ updates)

    case updates do
      [] ->
        IO.puts("waiting for new poll window #{poll_interval / 1000}s")
        Process.sleep(poll_interval)
        next_poll_interval = min(@max_poll_interval, 2 * poll_interval)

        next_offset = last_update_id
        IO.puts("next offset #{next_offset}")
        run(next_offset, next_poll_interval)

      _ ->
        IO.puts("processing #{length(updates)} updates")
        Enum.each(updates, &proccess_update/1)
        next_offset = last_update_id + 1
        IO.puts("next offset #{next_offset}")
        run(next_offset)
    end
  end

  defp proccess_update(_) do
  end

  def send_report(to \\ @admin_user_id) do
    send_weather(to)
    send_exchange_rates(to)
    send_today_tasks(to)
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
end
