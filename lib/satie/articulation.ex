defmodule Satie.Articulation do
  defstruct [:name]

  use Satie.Attachable

  @doc """

      iex> Articulation.new("accent")
      #Satie.Articulation<\\accent>

  """
  def new(name) do
    %__MODULE__{name: name}
  end

  defimpl String.Chars do
    def to_string(%@for{name: name}) do
      "\\#{name}"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = articulation, _opts) do
      concat([
        "#Satie.Articulation<",
        to_string(articulation),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = articulation) do
      to_string(articulation)
    end
  end
end
