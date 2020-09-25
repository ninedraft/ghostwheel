defmodule Ghostwheel.Exchange do
  use HTTPoison.Base

  @endpoint "https://www.cbr-xml-daily.ru/latest.js"

  def today() do
    %{body: response} = HTTPoison.get!(@endpoint)

    response
    |> Jason.decode!()
    |> extract_currencies(["EUR", "USD"])
  end

  def format(rates) do
    rates
    |> Enum.map(fn item ->
      {code, rate} = item
      rate_hr = :erlang.float_to_binary(rate, decimals: 2)
      "#{code}: #{rate_hr}₽"
    end)
    |> Enum.join("\n")
  end

  defp extract_currencies(doc, codes) do
    %{"rates" => rates} = doc

    rates
    |> Map.split(codes)
    |> elem(0)
    |> Enum.map(fn {code, r} -> {code, 1 / r} end)
  end
end
