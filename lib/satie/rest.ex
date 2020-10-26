defmodule Satie.Rest do
  defstruct [:written_duration]

  alias Satie.Duration

  def new(duration) do
    case Duration.assignable?(duration) do
      true ->
        %__MODULE__{ written_duration: duration }
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

defimpl Satie.ToLilypond, for: Satie.Rest do
  def to_lilypond(%Satie.Rest{written_duration: duration}) do
    "r" <> Satie.to_lilypond(duration)
  end
end
