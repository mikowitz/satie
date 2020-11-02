defmodule Satie.Note do
  @moduledoc false

  defstruct [:written_pitch, :written_duration, :id, attachments: [], spanners: []]

  alias Satie.{Duration, Pitch}

  def new(%Pitch{} = pitch, %Duration{} = duration) do
    case Duration.assignable?(duration) do
      true ->
        %__MODULE__{
          written_pitch: pitch,
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

defimpl Satie.ToLilypond, for: Satie.Note do
  import Satie.Lilypond.Helpers

  def to_lilypond(
        %Satie.Note{written_pitch: p, written_duration: d, attachments: a, spanners: s},
        _
      ) do
    [
      Satie.to_lilypond(p) <> Satie.to_lilypond(d),
      Enum.map(a, fn attachment -> indent(Satie.to_lilypond(attachment)) end),
      Enum.map(s, fn {spanner, position} ->
        indent(Satie.to_lilypond(spanner, spanner_position: position))
      end)
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end
end
