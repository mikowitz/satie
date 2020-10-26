defmodule Satie.Container do
  defstruct [:music]

  def new(music) do
    %__MODULE__{
      music: List.wrap(music)
    }
  end
end
