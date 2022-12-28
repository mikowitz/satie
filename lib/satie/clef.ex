defmodule Satie.Clef do
  @moduledoc """
  Models a musical clef
  """

  use Satie.Attachable, fields: [:name], location: :before, has_direction: false

  def new(name) do
    %__MODULE__{
      name: name,
      components: [
        before: [
          "\\clef #{inspect(name)}"
        ]
      ]
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{name: name}, _opts) do
      concat([
        "#Satie.Clef<",
        name,
        ">"
      ])
    end
  end
end
