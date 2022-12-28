defmodule Satie.StopPhrasingSlur do
  @moduledoc """
    Models the end of a phrasing slur
  """

  use Satie.Attachable, priority: -1, has_direction: false

  @doc """

      iex> StopPhrasingSlur.new()
      #Satie.StopPhrasingSlur<>

  """
  def new do
    %__MODULE__{
      components: [
        after: ["\\)"]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.StopPhrasingSlur<>"
    end
  end
end
