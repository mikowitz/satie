defmodule Satie.Tuplet do
  defstruct [:multiplier, :music]

  def new(multiplier, music) do
    %__MODULE__{
      multiplier: multiplier,
      music: List.wrap(music)
    }
  end
end
