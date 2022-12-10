defmodule Satie.StartSlur do
  @moduledoc """
  Models the beginning of a slur
  """
  defstruct []

  use Satie.Attachable

  @doc """

      iex> StartSlur.new
      #Satie.StartSlur<(>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}) do
      "("
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = start_slur, _opts) do
      concat([
        "#Satie.StartSlur<",
        to_string(start_slur),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = start_slur, _opts) do
      to_string(start_slur)
    end
  end
end
