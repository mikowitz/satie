defmodule Satie.Tie do
  @moduledoc false

  defstruct [:position, :id]

  def new(position \\ nil) do
    %__MODULE__{
      position: position,
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Tie do
  def to_lilypond(%Satie.Tie{position: position}, opts) do
    case opts[:spanner_position] do
      :beginning -> "#{position_prefix(position)}~"
      :middle -> "#{position_prefix(position)}~"
      :end -> nil
    end
  end

  defp position_prefix(nil), do: ""
  defp position_prefix(:up), do: "^"
  defp position_prefix(:down), do: "_"
end
