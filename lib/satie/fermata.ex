defmodule Satie.Fermata do
  @moduledoc """
  Models a fermata
  """

  use Satie.Attachable, fields: [:length]

  @valid_lengths ~w(veryshort short fermata long verylong)a

  @doc """

      iex> Fermata.new()
      #Satie.Fermata<fermata>

      iex> Fermata.new(:short)
      #Satie.Fermata<shortfermata>

  """
  def new(length \\ :fermata) when length in @valid_lengths do
    %__MODULE__{
      length: length,
      components: [
        after: [
          "\\#{_symbol_from_length(length)}"
        ]
      ]
    }
  end

  def _symbol_from_length(:fermata), do: "fermata"
  def _symbol_from_length(length), do: "#{length}fermata"

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{length: length}, _opts) do
      concat([
        "#Satie.Fermata<",
        @for._symbol_from_length(length),
        ">"
      ])
    end
  end
end
