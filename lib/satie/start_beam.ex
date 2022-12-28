defmodule Satie.StartBeam do
  @moduledoc """
  Models the start of a beam
  """

  use Satie.Attachable

  @doc """

      iex> StartBeam.new
      #Satie.StartBeam<>

  """
  def new do
    %__MODULE__{
      components: [
        after: ["["]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.StartBeam<>"
    end
  end
end
