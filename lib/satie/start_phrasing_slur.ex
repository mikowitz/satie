defmodule Satie.StartPhrasingSlur do
  defstruct []

  use Satie.Attachable

  @doc """

      iex> StartPhrasingSlur.new
      #Satie.StartPhrasingSlur<>

  """
  def new() do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}) do
      "\\("
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.StartPhrasingSlur<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = start_phrasing_slur) do
      to_string(start_phrasing_slur)
    end
  end
end
