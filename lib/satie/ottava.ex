defmodule Satie.Ottava do
  @moduledoc """
    Models an ottava setting
  """

  use Satie.Attachable, fields: [:degree], location: :before, has_direction: false

  def new(degree) when is_integer(degree) do
    %__MODULE__{
      degree: degree,
      components: [
        before: [
          "\\ottava ##{degree}"
        ]
      ]
    }
  end

  def new(degree), do: {:error, :ottava_new, degree}

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{degree: degree}, _opts) do
      concat([
        "#Satie.Ottava<",
        inspect(degree),
        ">"
      ])
    end
  end
end
