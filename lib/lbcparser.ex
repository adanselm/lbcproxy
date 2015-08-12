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
    price = extract_price(List.first(F.find(elem, ".price")))
    picture = extract_picture(F.find(elem, ".image .image-and-nb"))

    %{ :link => link, :title => title, :date => date, :category => category,
      :placement => placement, :price => price, :time => time, :id => id,
      :picture => picture
    }
  end

  defp extract_datetime(raw_datetime) do
    [_date, _time] = Enum.map(raw_datetime, fn x -> F.text(x) |> String.strip end)
  end

  defp extract_price(nil) do
    ""
  end
  defp extract_price(raw_price) do
    raw_price |> F.text |> String.strip
  end

  defp extract_picture([]) do
    ""
  end
  defp extract_picture(raw_picture) do
    raw_picture |> Floki.attribute("img", "src") |> List.first
  end

end
