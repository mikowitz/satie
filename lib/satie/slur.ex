defmodule Satie.Slur do
  @moduledoc false

  defstruct [:position, :id]

  def new(position \\ nil) do
    %__MODULE__{
      position: position,
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Slur do
  def to_lilypond(%Satie.Slur{position: position}, opts) do
    case opts[:spanner_position] do
      :beginning -> "#{position_prefix(position)}("
      :middle -> nil
      :end -> ")"
    end
  end

  defp position_prefix(nil), do: ""
  defp position_prefix(:up), do: "^"
  defp position_prefix(:down), do: "_"
end
