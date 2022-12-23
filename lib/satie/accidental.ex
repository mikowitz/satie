defmodule Satie.Accidental do
  @moduledoc """
  Models an accidental
  """

  defstruct [:name, :semitones]

  def new(accidental), do: Satie.ToAccidental.from(accidental)

  defimpl String.Chars do
    def to_string(%@for{name: name}), do: name
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = accidental, _opts) do
      concat([
        "#Satie.Accidental<",
        to_string(accidental),
        ">"
      ])
    end
  end
end
