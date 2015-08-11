defmodule Parser do
  use Behaviour

  @doc """
  Returns structured data from raw html.
  """
  defcallback parse(String.t) :: Map

end
