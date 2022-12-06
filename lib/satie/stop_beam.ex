defmodule Satie.StopBeam do
  @moduledoc """
    Models the end of a beam
  """
  defstruct []

  use Satie.Attachable, priority: -1

  @doc """

      iex> StopBeam.new()
      #Satie.StopBeam<>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}), do: "]"
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.StopBeam<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = stop_beam), do: to_string(stop_beam)
  end
end
