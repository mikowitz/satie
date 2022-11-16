defmodule Satie.StartSlur do
  defstruct [:position]

  use Satie.Attachable

  import Satie.Validations

  @doc """

      iex> StartSlur.new
      #Satie.StartSlur<- (>

      iex> StartSlur.new(:up)
      #Satie.StartSlur<^ (>
  """
  def new(position \\ :neutral) do
    with position <- validate_position(position) do
      %__MODULE__{position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{position: position}) do
      position_indicator(position) <> " ("
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = start_slur, _opts) do
      concat([
        "#Satie.StartSlur<",
        to_string(start_slur),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = start_slur) do
      to_string(start_slur)
    end
  end
end
