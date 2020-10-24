defmodule Satie.Chord do
  defstruct [:written_pitches, :written_duration]

  alias Satie.{Duration, Pitch}

  def new(pitch = %Pitch{}, duration = %Duration{}) do
    new(List.wrap(pitch), duration)
  end
  def new(pitches, duration = %Duration{}) when is_list pitches do
    with true <- validate_pitches(pitches) do
      case Duration.assignable?(duration) do
        true ->
          %__MODULE__{
            written_pitches: pitches,
            written_duration: duration
          }
        false ->
          raise_unassignable_duration_error(duration)
      end
    else
      {:error, pitch} -> raise_unassignable_pitch_error(pitch)
    end
  end

  ## PRIVATE

  defp validate_pitches([]), do: true
  defp validate_pitches([%Pitch{}|pitches]), do: validate_pitches(pitches)
  defp validate_pitches([x|_]), do: {:error, x}

  defp raise_unassignable_duration_error(%Duration{numerator: n, denominator: d}) do
    raise Satie.UnassignableDurationError,
      message: "Duration<#{n}, #{d}> is unassignable"
  end

  defp raise_unassignable_pitch_error(x) do
    raise Satie.UnassignablePitchError,
      message: "#{inspect x} cannot be assigned as a pitch"
  end
end
