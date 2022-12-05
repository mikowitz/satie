defmodule Satie.Clef do
  defstruct [:name]

  use Satie.Attachable, location: :before, has_direction: false

  def new(name) do
    %__MODULE__{name: name}
  end

  defimpl String.Chars do
    def to_string(%@for{name: name}), do: name
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{name: name}, _opts) do
      concat([
        "#Satie.Clef<",
        name,
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{name: name}) do
      ~s(\\clef "#{name}")
    end
  end
end
