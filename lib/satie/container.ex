defmodule Satie.Container do
  defstruct [:music]

  def new(music) do
    %__MODULE__{
      music: List.wrap(music)
    }
  end

  defdelegate append(container, element_or_elements), to: Satie
  defdelegate insert(container, element_or_elements), to: Satie
  defdelegate insert(container, element_or_elements, index), to: Satie
end
