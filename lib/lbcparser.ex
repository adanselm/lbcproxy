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
    title = List.first(F.find(elem, ".title")) |> F.text |> clean_string
    category = List.first(F.find(elem, ".category")) |> F.text |> clean_string
    placement = List.first(F.find(elem, ".placement")) |> F.text
                |> String.split(["/"], trim: true) |> clean_string
    price = extract_price(List.first(F.find(elem, ".price")))
    picture = extract_picture(F.find(elem, ".image .image-and-nb"))

    %{ :link => link, :title => title, :date => date, :category => category,
      :placement => placement, :price => price, :time => time, :id => id,
      :picture => picture
    }
  end

  defp extract_datetime(raw_datetime) do
    Enum.map(raw_datetime, fn x -> F.text(x) |> clean_string end)
  end

  defp extract_price(nil) do
    ""
  end
  defp extract_price(raw_price) do
    raw_price |> F.text |> clean_string
  end

  defp extract_picture([]) do
    ""
  end
  defp extract_picture(raw_picture) do
    raw_picture |> Floki.attribute("img", "src") |> List.first
  end

  defp clean_string(list) when is_list(list) do
    Enum.map(list, fn x -> clean_string(x) end)
  end
  defp clean_string(str) do
    unless String.printable?(str) do
      {:ok, str} = Codepagex.to_string(:iso_8859_15, str)
    end

    str
    |> String.strip
    |> String.split([" ", "\t", "\n"], trim: true)
    |> Enum.join(" ")
  end

end
