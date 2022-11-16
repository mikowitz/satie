defmodule Satie.Articulation do
  defstruct [:name, :position]

  use Satie.Attachable
  import Satie.Validations

  def new(name, position \\ :neutral) do
    with position <- validate_position(position) do
      %__MODULE__{name: name, position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{name: name, position: position}) do
      position_indicator(position) <> " \\#{name}"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = articulation, _opts) do
      concat([
        "#Satie.Articulation<",
        to_string(articulation),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = articulation) do
      to_string(articulation)
    end
  end
end
