defmodule Ghostwheel.Todoist do
  use HTTPoison.Base

  @endpoint "https://api.todoist.com/rest/v1/tasks"
  @token "16c9f1f9d465bed1bfd6cbf7262b9021308e8763"
  @item_fields ["id", "url", "content"]

  def today() do
    %{body: response} =
      HTTPoison.get!(
        @endpoint,
        [Authorization: "Bearer " <> @token],
        params: [filter: "(today | overdue) & (+me | !assigned)"]
      )

    response
    |> Jason.decode!()
    |> Enum.map(&make_task/1)
  end

  def tasks_markdown_list(list) do
    list
    |> Enum.with_index()
    |> Enum.map(fn {task, i} ->
      md = task_markdown(task)
      "#{i}. #{md}"
    end)
    |> Enum.join("\n")
  end

  defp task_markdown(task) do
    content = Map.get(task, "content", "")
    url = Map.get(task, "url", "")
    "[#{content}](#{url})"
  end

  defp make_task(obj) do
    Map.take(obj, @item_fields)
  end
end
