defmodule Satie.StopHairpin do
  @moduledoc """
    models the end of a hairpin
  """

  use Satie.Attachable, priority: -1, has_direction: false

  @doc """

      iex> StopHairpin.new()
      #Satie.StopHairpin<>
  """
  def new do
    %__MODULE__{
      components: [
        after: ["\\!"]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.StopHairpin<>"
    end
  end
end
