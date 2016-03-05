defmodule Lbcparser do
  @behaviour Parser
  alias Floki, as: F

  def parse(html) do
    F.find(html, ".tabsContent a")
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
    [date, time] = extract_datetime( F.find(elem, ".item_infos aside .item_supp") )
    title = List.first(F.find(elem, ".item_title")) |> F.text |> clean_string
    category = List.first(F.find(elem, ".item_supp")) |> F.text |> clean_string
    placement = Enum.at(F.find(elem, ".item_supp"), 1) |> F.text
                |> String.split(["/"], trim: true) |> clean_string
    price = extract_price(List.first(F.find(elem, ".item_price")))
    picture = extract_picture(F.find(elem, ".item_imagePic"))

    %{ :link => link, :title => title, :date => date, :category => category,
      :placement => placement, :price => price, :time => time, :id => id,
      :picture => picture
    }
  end

  defp extract_datetime(raw_datetime) do
    List.first(raw_datetime) |> F.text |> clean_string |> String.split(",", trim: true)
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
    raw_picture |> Floki.attribute("span", "data-imgsrc") |> List.first
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
