defmodule Satie.StopPhrasingSlur do
  @moduledoc """
    Models the end of a phrasing slur
  """
  defstruct []

  use Satie.Attachable, priority: -1

  @doc """

      iex> StopPhrasingSlur.new()
      #Satie.StopPhrasingSlur<>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}), do: "\\)"
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.StopPhrasingSlur<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = stop_phrasing_slur, _opts) do
      to_string(stop_phrasing_slur)
    end
  end
end
