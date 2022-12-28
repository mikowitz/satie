defmodule Satie.StopBeam do
  @moduledoc """
    Models the end of a beam
  """

  use Satie.Attachable, priority: -1, has_direction: false

  @doc """

      iex> StopBeam.new()
      #Satie.StopBeam<>

  """
  def new do
    %__MODULE__{
      components: [
        after: ["]"]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.StopBeam<>"
    end
  end
end
