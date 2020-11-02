defmodule Satie.Rest do
  @moduledoc false

  defstruct [:written_duration, :id, attachments: [], spanners: []]

  alias Satie.Duration

  def new(duration) do
    case Duration.assignable?(duration) do
      true ->
        %__MODULE__{
          written_duration: duration,
          id: make_ref()
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

defimpl Satie.ToLilypond, for: Satie.Rest do
  def to_lilypond(%Satie.Rest{written_duration: duration}, _) do
    "r" <> Satie.to_lilypond(duration)
  end
end
