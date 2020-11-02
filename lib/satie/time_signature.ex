defmodule Satie.TimeSignature do
  @moduledoc false

  defstruct [:numerator, :denominator]

  def new(numerator, denominator) do
    %__MODULE__{
      numerator: numerator,
      denominator: denominator
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.TimeSignature do
  def to_lilypond(%Satie.TimeSignature{numerator: n, denominator: d}) do
    "\\time #{n}/#{d}"
  end
end
