defmodule Satie.RepeatTie do
  @moduledoc """
  Models a repeat tie
  """
  defstruct []

  use Satie.Attachable

  @doc """

      iex> RepeatTie.new()
      #Satie.RepeatTie<>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}) do
      "\\repeatTie"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.RepeatTie<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = repeat_tie) do
      to_string(repeat_tie)
    end
  end
end
