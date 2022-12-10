defmodule Satie.LaissezVibrer do
  @moduledoc """
  Models a laissez vibrer tie
  """

  defstruct []

  use Satie.Attachable

  @doc """

      iex> LaissezVibrer.new()
      #Satie.LaissezVibrer<>

  """
  def new do
    %__MODULE__{}
  end

  defimpl String.Chars do
    def to_string(%@for{}) do
      "\\laissezVibrer"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.LaissezVibrer<",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = laissez_vibrer, _opts) do
      to_string(laissez_vibrer)
    end
  end
end
