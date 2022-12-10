defmodule Satie.Tie do
  @moduledoc """
  Models a tie
  """

  defstruct []

  use Satie.Attachable

  @doc """

      iex> Tie.new()
      #Satie.Tie<>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}) do
      "~"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.Tie<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = tie, _opts) do
      to_string(tie)
    end
  end
end
