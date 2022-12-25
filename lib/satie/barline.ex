defmodule Satie.Barline do
  @moduledoc """
    models a barline
  """

  defstruct [:symbol]

  use Satie.Attachable, priority: 10, has_direction: false

  def new(symbol) when is_bitstring(symbol) do
    %__MODULE__{symbol: symbol}
  end

  defimpl String.Chars do
    def to_string(%@for{symbol: symbol}) do
      "\\bar #{inspect(symbol)}"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{symbol: symbol}, _opts) do
      concat([
        "#Satie.Barline<",
        symbol,
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{symbol: symbol}, _opts) do
      "\\bar #{inspect(symbol)}"
    end
  end
end
