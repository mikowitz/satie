defmodule Satie.Barline do
  @moduledoc false

  defstruct [:symbol]

  def new(symbol) do
    %__MODULE__{
      symbol: symbol
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Barline do
  def to_lilypond(%Satie.Barline{symbol: symbol}) do
    ~s(\\bar "#{symbol}")
  end

  defp position_prefix(nil), do: ""
  defp position_prefix(:up), do: "^"
  defp position_prefix(:down), do: "_"
end
