defmodule Satie.Beam do
  @moduledoc false

  defstruct [:id]

  def new do
    %__MODULE__{
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Beam do
  def to_lilypond(%Satie.Beam{}, opts) do
    case opts[:spanner_position] do
      :beginning -> "["
      :middle -> nil
      :end -> "]"
    end
  end
end
