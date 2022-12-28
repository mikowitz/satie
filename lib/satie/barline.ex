defmodule Satie.Barline do
  @moduledoc """
    models a barline
  """

  use Satie.Attachable, fields: [:symbol], priority: 10, has_direction: false

  def new(symbol) when is_bitstring(symbol) do
    %__MODULE__{
      symbol: symbol,
      components: [
        after: ["\\bar #{inspect(symbol)}"]
      ]
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{symbol: symbol}, _opts) do
      concat([
        "#Satie.Barline<",
        "#{inspect(symbol)}",
        ">"
      ])
    end
  end
end
