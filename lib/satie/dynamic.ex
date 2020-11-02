defmodule Satie.Dynamic do
  @moduledoc false

  defstruct [:name, :position]

  def new(name, position \\ nil) do
    %__MODULE__{
      name: name,
      position: position
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Dynamic do
  def to_lilypond(%Satie.Dynamic{name: name, position: position}, _) do
    position_prefix(position) <> "\\" <> name
  end

  defp position_prefix(nil), do: ""
  defp position_prefix(:up), do: "^"
  defp position_prefix(:down), do: "_"
end
