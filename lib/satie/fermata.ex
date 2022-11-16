defmodule Satie.Fermata do
  defstruct [:length, :position]

  use Satie.Attachable

  @valid_lengths ~w(veryshort short fermata long verylong)a
  import Satie.Validations

  @doc """

      iex> Fermata.new()
      #Satie.Fermata<- \\fermata>

      iex> Fermata.new(:fermata, :up)
      #Satie.Fermata<^ \\fermata>

      iex> Fermata.new(:short)
      #Satie.Fermata<- \\shortfermata>

  """
  def new(length \\ :fermata, position \\ :neutral) when length in @valid_lengths do
    with position <- validate_position(position) do
      %__MODULE__{length: length, position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{length: length, position: position}) do
      position_indicator(position) <> " \\#{command_from_length(length)}"
    end

    defp command_from_length(:fermata), do: "fermata"
    defp command_from_length(command), do: "#{command}fermata"
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = fermata, _opts) do
      concat([
        "#Satie.Fermata<",
        to_string(fermata),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = fermata) do
      to_string(fermata)
    end
  end
end
