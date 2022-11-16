defmodule Satie.StartBeam do
  defstruct [:position]

  use Satie.Attachable

  import Satie.Validations

  @doc """

      iex> StartBeam.new
      #Satie.StartBeam<- [>

      iex> StartBeam.new(:up)
      #Satie.StartBeam<^ [>
  """
  def new(position \\ :neutral) do
    with position <- validate_position(position) do
      %__MODULE__{position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{position: position}) do
      position_indicator(position) <> " ["
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = start_beam, _opts) do
      concat([
        "#Satie.StartBeam<",
        to_string(start_beam),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = start_beam) do
      to_string(start_beam)
    end
  end
end
