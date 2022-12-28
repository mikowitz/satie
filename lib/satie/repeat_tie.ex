defmodule Satie.RepeatTie do
  @moduledoc """
  Models a repeat tie
  """

  use Satie.Attachable

  @doc """

      iex> RepeatTie.new()
      #Satie.RepeatTie<>

  """
  def new do
    %__MODULE__{
      components: [
        after: ["\\repeatTie"]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.RepeatTie<>"
    end
  end
end
