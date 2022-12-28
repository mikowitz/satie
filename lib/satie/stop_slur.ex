defmodule Satie.StopSlur do
  @moduledoc """
    Models the end of a slur
  """

  use Satie.Attachable, priority: -1, has_direction: false

  @doc """

      iex> StopSlur.new()
      #Satie.StopSlur<>

  """
  def new do
    %__MODULE__{
      components: [
        after: [")"]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.StopSlur<>"
    end
  end
end
