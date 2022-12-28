defmodule Satie.Articulation do
  @moduledoc """
  Models an articulation
  """

  use Satie.Attachable,
    fields: [:name]

  @doc """

      iex> Articulation.new("accent")
      #Satie.Articulation<accent>

  """
  def new(name) do
    %__MODULE__{
      name: name,
      components: [
        after: ["\\#{name}"]
      ]
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{name: name}, _opts) do
      concat([
        "#Satie.Articulation<",
        name,
        ">"
      ])
    end
  end
end
