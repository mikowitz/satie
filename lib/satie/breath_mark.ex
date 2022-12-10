defmodule Satie.BreathMark do
  @moduledoc """
  Models a breath mark
  """

  defstruct []

  use Satie.Attachable

  @doc """

      iex> BreathMark.new()
      #Satie.BreathMark<>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}) do
      "\\breathe"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.BreathMark<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = breath_mark, _opts) do
      to_string(breath_mark)
    end
  end
end
