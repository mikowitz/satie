defmodule Satie.StartPhrasingSlur do
  @moduledoc """
  Models the beginning of a phrasing slur
  """

  use Satie.Attachable

  @doc """

      iex> StartPhrasingSlur.new()
      #Satie.StartPhrasingSlur<>

  """
  def new do
    %__MODULE__{
      components: [
        after: ["\\("]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.StartPhrasingSlur<>"
    end
  end
end
