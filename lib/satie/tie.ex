defmodule Satie.Tie do
  @moduledoc """
  Models a tie
  """

  use Satie.Attachable

  @doc """

      iex> Tie.new()
      #Satie.Tie<>

  """
  def new do
    %__MODULE__{
      components: [
        after: ["~"]
      ]
    }
  end

  defimpl Inspect do
    def inspect(%@for{}, _opts) do
      "#Satie.Tie<>"
    end
  end
end
