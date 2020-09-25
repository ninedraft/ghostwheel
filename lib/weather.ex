defmodule Ghostwheel.Weather do
  use HTTPoison.Base
  use Memoize

  @wttr "https://wttr.in/Moscow"
  @expires_in 3600 * 1000

  @spec weather :: binary
  defmemo weather(), expires_in: @expires_in do
    %{body: report} =
      HTTPoison.get!(
        @wttr,
        ["User-Agent": "curl"],
        params: ["no-terminal": 1]
      )

    report
    |> String.split("┌")
    |> List.first()
    |> String.trim()
  end
end
