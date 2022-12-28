defmodule Satie.StartSlur do
  @moduledoc """
  Models the beginning of a slur
  """

  use Satie.Attachable

  @doc """

      iex> StartSlur.new
      #Satie.StartSlur<>

  """
  def new do
    %__MODULE__{
      components: [
        after: ["("]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.StartSlur<>"
    end
  end
end
