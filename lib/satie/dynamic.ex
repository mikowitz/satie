defmodule Satie.Dynamic do
  @moduledoc """
  Models a static dynamic
  """

  defstruct [:name]

  use Satie.Attachable

  @doc """

      iex> Dynamic.new("ff")
      #Satie.Dynamic<\\ff>

      iex> Dynamic.new("ppp")
      #Satie.Dynamic<\\ppp>

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

    def inspect(%@for{} = dynamic, _opts) do
      concat([
        "#Satie.Dynamic<",
        to_string(dynamic),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = dynamic, _opts) do
      to_string(dynamic)
    end
  end
end
