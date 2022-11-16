defmodule Satie.Tie do
  defstruct [:position]

  use Satie.Attachable

  import Satie.Validations

  @doc """

      iex> Tie.new()
      #Satie.Tie<>

      iex> Tie.new(:down)
      #Satie.Tie<down>

      iex> Tie.new("anything")
      #Satie.Tie<>

  """
  def new(position \\ :neutral) do
    with position <- validate_position(position) do
      %__MODULE__{position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{position: position}) do
      position_indicator(position) <> " ~"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{position: position}, _opts) do
      concat([
        "#Satie.Tie<",
        format_position(position),
        ">"
      ])
    end

    defp format_position(:neutral), do: ""
    defp format_position(position), do: to_string(position)
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = tie) do
      String.Chars.to_string(tie)
    end
  end
end
