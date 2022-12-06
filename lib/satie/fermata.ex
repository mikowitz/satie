defmodule Satie.Fermata do
  @moduledoc """
  Models a fermata
  """

  defstruct [:length]

  use Satie.Attachable

  @valid_lengths ~w(veryshort short fermata long verylong)a

  @doc """

      iex> Fermata.new()
      #Satie.Fermata<\\fermata>

      iex> Fermata.new(:short)
      #Satie.Fermata<\\shortfermata>

  """
  def new(length \\ :fermata) when length in @valid_lengths do
    %__MODULE__{length: length}
  end

  defimpl String.Chars do
    def to_string(%@for{length: length}) do
      "\\#{command_from_length(length)}"
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
