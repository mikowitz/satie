defmodule Satie.Tuplet do
  defstruct [:multiplier, :music]

  def new(multiplier, music) do
    %__MODULE__{
      multiplier: multiplier,
      music: List.wrap(music)
    }
  end

  defdelegate append(container, element_or_elements), to: Satie
  defdelegate insert(container, element_or_elements), to: Satie
  defdelegate insert(container, element_or_elements, index), to: Satie
end
