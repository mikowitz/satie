defmodule Satie.LaissezVibrer do
  @moduledoc """
  Models a laissez vibrer tie
  """

  use Satie.Attachable

  @doc """

      iex> LaissezVibrer.new()
      #Satie.LaissezVibrer<>

  """
  def new do
    %__MODULE__{
      components: [
        after: [
          "\\laissezVibrer"
        ]
      ]
    }
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
end
