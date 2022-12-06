defmodule Satie.StartBeam do
  @moduledoc """
  Models the start of a beam
  """
  defstruct []

  use Satie.Attachable

  @doc """

      iex> StartBeam.new
      #Satie.StartBeam<>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}) do
      "["
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.StartBeam<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = start_beam) do
      to_string(start_beam)
    end
  end
end
