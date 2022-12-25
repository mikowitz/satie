defmodule Satie.StopHairpin do
  @moduledoc """
    models the end of a hairpin
  """

  defstruct []

  use Satie.Attachable, priority: -1

  @doc """

      iex> StopHairpin.new()
      #Satie.StopHairpin<>
  """
  def new, do: %__MODULE__{}

  defimpl String.Chars do
    def to_string(%@for{}), do: "\\!"
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.StopHairpin<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = stop_hairpin, _opts), do: to_string(stop_hairpin)
  end
end
