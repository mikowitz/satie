defmodule Satie.Hairpin do
  @moduledoc false

  defstruct [:symbol, :position, :id]

  def crescendo(position \\ nil) do
    %__MODULE__{
      symbol: "<",
      position: position,
      id: make_ref()
    }
  end

  def decrescendo(position \\ nil) do
    %__MODULE__{
      symbol: ">",
      position: position,
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Hairpin do
  def to_lilypond(%Satie.Hairpin{symbol: symbol, position: position}, opts) do
    case opts[:spanner_position] do
      :beginning -> "#{position_prefix(position)}\\#{symbol}"
      :middle -> nil
      :end -> "\\!"
    end
  end

  defp position_prefix(nil), do: ""
  defp position_prefix(:up), do: "^"
  defp position_prefix(:down), do: "_"
end
