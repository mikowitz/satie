defmodule Satie.RepeatTie do
  defstruct [:position]

  use Satie.Attachable

  import Satie.Validations

  @doc """

      iex> RepeatTie.new()
      #Satie.RepeatTie<>

      iex> RepeatTie.new(:up)
      #Satie.RepeatTie<up>

      iex> RepeatTie.new("anything")
      #Satie.RepeatTie<>

  """
  def new(position \\ :neutral) do
    with position <- validate_position(position) do
      %__MODULE__{position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{position: position}) do
      position_indicator(position) <> " \\repeatTie"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{position: position}, _opts) do
      concat([
        "#Satie.RepeatTie<",
        format_position(position),
        ">"
      ])
    end

    defp format_position(:neutral), do: ""
    defp format_position(position), do: to_string(position)
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = repeat_tie) do
      to_string(repeat_tie)
    end
  end
end
