defmodule Satie.Articulation do
  @moduledoc false

  defstruct [:name, :position]

  def new(name, position \\ nil) do
    %__MODULE__{
      name: name,
      position: position
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Articulation do
  def to_lilypond(%Satie.Articulation{name: name, position: position}) do
    position_prefix(position) <> "\\" <> name
  end

  defp position_prefix(nil), do: ""
  defp position_prefix(:up), do: "^"
  defp position_prefix(:down), do: "_"
end
