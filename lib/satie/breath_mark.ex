defmodule Satie.BreathMark do
  @moduledoc """
  Models a breath mark
  """

  use Satie.Attachable, has_direction: false

  @doc """

      iex> BreathMark.new()
      #Satie.BreathMark<>

  """
  def new do
    %__MODULE__{
      components: [
        after: ["\\breathe"]
      ]
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{}, _opts) do
      concat([
        "#Satie.BreathMark<",
        ">"
      ])
    end
  end
end
