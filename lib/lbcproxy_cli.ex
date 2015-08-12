defmodule LbcproxyCli do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    #Lbcproxy.Supervisor.start_link
  end

  def main(args) do
    args |> parse_args |> do_process
  end

  defp parse_args(args) do
    options = OptionParser.parse(args)

    case options do
      {flags, terms, _} when length(terms) > 0 -> {flags, terms}
      {[help_categories: true], _, _} -> :help_categories
      {[help_regions: true], _, _} -> :help_regions
      {[help: true], _, _} -> :help
      _ -> :help
    end
  end

  defp do_process({flags, terms}) do
    region = flags[:region] || "all"
    category = flags[:category] || "annonces"
    terms_str = Enum.join(terms, " ")

    Lbcproxy.search(terms_str, String.to_atom(region), String.to_atom(category))
    |> Enum.take(10) |> format_output
  end

  defp do_process(:help) do
    IO.puts """
      Usage:
      ./lbcproxy_cli porsche cayenne --category voitures
      Options:
      --category Specify search section
      --region Specify search region
      --help  Show this help message.
      --help-categories  Show the list of available categories.
      --help-regions Show the list of available regions.
      Description:
      Searches www.leboncoin.fr for a given product.
    """

    System.halt(0)
  end

  defp do_process(:help_categories) do
    Enum.map(Lbcproxy.all_categories, fn x -> to_string(x) end)
    |> Enum.join(", ")
    |> IO.puts

    System.halt(0)
  end

  defp do_process(:help_regions) do
    Enum.map(Lbcproxy.all_regions, fn x -> to_string(x) end)
    |> Enum.join(", ")
    |> IO.puts

    System.halt(0)
  end

  defp format_output([]) do
  end
  defp format_output([item | rest]) do
    format_output item
    format_output rest
  end
  defp format_output(item) do
    place = Enum.join(item.placement, ", ")
    line1 = [:yellow, "[", item.date, ", ", item.time, "] ",
      :blue, "[", place, "] ",
      :green, "[", item.category, "]\t\t",
      :white, :bright, item.title,
      "\t\t", :underline, :red, item.price]
    IO.puts IO.ANSI.format line1, true
  end

end
