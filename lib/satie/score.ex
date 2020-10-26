defmodule Satie.Score do
  defstruct [:music, :name]

  def new(music, opts \\ []) do
    %__MODULE__{
      music: List.wrap(music),
      name: opts[:name]
    }
  end
end
