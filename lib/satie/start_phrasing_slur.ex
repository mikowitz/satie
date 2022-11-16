defmodule Satie.StartPhrasingSlur do
  defstruct [:position]

  use Satie.Attachable

  import Satie.Validations

  @doc """

      iex> StartPhrasingSlur.new
      #Satie.StartPhrasingSlur<- \\(>

      iex> StartPhrasingSlur.new(:up)
      #Satie.StartPhrasingSlur<^ \\(>
  """
  def new(position \\ :neutral) do
    with position <- validate_position(position) do
      %__MODULE__{position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{position: position}) do
      position_indicator(position) <> " \\("
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = start_phrasing_slur, _opts) do
      concat([
        "#Satie.StartPhrasingSlur<",
        to_string(start_phrasing_slur),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = start_phrasing_slur) do
      to_string(start_phrasing_slur)
    end
  end
end
