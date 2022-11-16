defmodule Satie.StopSlur do
  defstruct []

  use Satie.Attachable, priority: -1

  @doc """

      iex> StopSlur.new()
      #Satie.StopSlur<>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}), do: ")"
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.StopSlur<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = stop_slur), do: to_string(stop_slur)
  end
end
