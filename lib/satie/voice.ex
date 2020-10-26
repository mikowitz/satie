defmodule Satie.Voice do
  defstruct [:music, :name]

  def new(music, opts \\ []) do
    %__MODULE__{
      music: List.wrap(music),
      name: opts[:name]
    }
  end

  defdelegate append(container, element_or_elements), to: Satie
  defdelegate insert(container, element_or_elements), to: Satie
  defdelegate insert(container, element_or_elements, index), to: Satie
end
