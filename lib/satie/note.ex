defmodule Satie.Note do
  @moduledoc false

  defstruct [:written_pitch, :written_duration]

  alias Satie.{Duration, Pitch}

  def new(%Pitch{} = pitch, %Duration{} = duration) do
    case Duration.assignable?(duration) do
      true ->
        %__MODULE__{
          written_pitch: pitch,
          written_duration: duration
        }

      false ->
        raise_unassignable_duration_error(duration)
    end
  end

  ## PRIVATE

  defp raise_unassignable_duration_error(%Duration{numerator: n, denominator: d}) do
    raise Satie.UnassignableDurationError,
      message: "Duration<#{n}, #{d}> is unassignable"
  end
end

defimpl Satie.ToLilypond, for: Satie.Note do
  def to_lilypond(%Satie.Note{written_pitch: p, written_duration: d}) do
    Satie.to_lilypond(p) <> Satie.to_lilypond(d)
  end
end
