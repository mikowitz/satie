defmodule Satie.Note do
  defstruct [:written_pitch, :written_duration]

  alias Satie.{Duration, Pitch}

  def new(pitch = %Pitch{}, duration = %Duration{}) do
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
