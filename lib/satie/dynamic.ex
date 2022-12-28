defmodule Satie.Dynamic do
  @moduledoc """
  Models a static dynamic
  """

  use Satie.Attachable, fields: [:dynamic]

  @doc """

      iex> Dynamic.new("ff")
      #Satie.Dynamic<ff>

  """
  def new(dynamic) do
    %__MODULE__{
      dynamic: dynamic,
      components: [
        after: [
          "\\#{dynamic}"
        ]
      ]
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{dynamic: dynamic}, _opts) do
      concat([
        "#Satie.Dynamic<",
        dynamic,
        ">"
      ])
    end
  end
end
