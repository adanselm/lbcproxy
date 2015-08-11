defmodule Lbcparser do
  @behaviour Parser
  alias Floki, as: F

  def parse(html) do
    filter = fn (x, acc) ->
      case F.find(x, ".lbc") do
        [] -> acc
        _  -> [x | acc]
      end
    end

    F.find(html, ".list-lbc a")
    |> List.foldl([], filter)
    |> extract
  end

  defp extract([elem | rest]) do
    [extract(elem) | extract(rest)]
  end
  defp extract([]) do
    []
  end
  defp extract(elem) do
    link = List.first(F.attribute(elem, "a", "href"))
    [id] = Regex.run(~r|/([0-9]+)\.htm|, link, capture: :all_but_first)
    [date, time] = extract_datetime( tl(F.find(elem, ".date div")) )
    title = List.first(F.find(elem, ".title")) |> F.text |> String.strip
    category = List.first(F.find(elem, ".category")) |> F.text |> String.strip
    placement = List.first(F.find(elem, ".placement")) |> F.text
                |> String.split([" ", "\t", "\n", "/"], trim: true)
    price = List.first(F.find(elem, ".price"))
            |> F.text |> String.strip #|> extract_price

    %{ :link => link, :title => title, :date => date, :category => category,
      :placement => placement, :price => price, :time => time, :id => id }
  end

  defp extract_datetime(raw_datetime) do
    [_date, _time] = Enum.map(raw_datetime, fn x -> F.text(x) |> String.strip end)
  end

  defp extract_price(raw_price) do
    <<128, 194, 160, invprice :: binary>> = String.reverse(raw_price)
    {p, _} = String.replace(invprice, " ", "") |> String.reverse |> Integer.parse
    p
  end

end
