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
  def to_lilypond(%Satie.Barline{symbol: symbol}, _) do
    ~s(\\bar "#{symbol}")
  end
end
