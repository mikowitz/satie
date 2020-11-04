defmodule Satie.Chord do
  @moduledoc false

  use Satie.Leaf, [:written_pitches, :written_duration]

  alias Satie.Pitch

  def new(%Pitch{} = pitch, %Duration{} = duration) do
    new(List.wrap(pitch), duration)
  end

  def new(pitches, %Duration{} = duration) when is_list(pitches) do
    case validate_pitches(pitches) do
      true ->
        case Duration.assignable?(duration) do
          true ->
            %__MODULE__{
              written_pitches: pitches,
              written_duration: duration,
              id: make_ref()
            }

          false ->
            raise_unassignable_duration_error(duration)
        end

      {:error, pitch} ->
        raise_unassignable_pitch_error(pitch)
    end
  end

  ## PRIVATE

  defp validate_pitches([]), do: true
  defp validate_pitches([%Pitch{} | pitches]), do: validate_pitches(pitches)
  defp validate_pitches([x | _]), do: {:error, x}

  defp raise_unassignable_pitch_error(x) do
    raise Satie.UnassignablePitchError,
      message: "#{inspect(x)} cannot be assigned as a pitch"
  end
end

defimpl Satie.ToLilypond, for: Satie.Chord do
  import Satie.Lilypond.Helpers

  def to_lilypond(
        %Satie.Chord{written_pitches: ps, written_duration: d, attachments: a, spanners: s},
        _
      ) do
    [
      pitches_to_lilypond(ps) <> Satie.to_lilypond(d),
      attachments_to_lilypond(a),
      spanners_to_lilypond(s)
    ]
    |> join()
  end

  defp pitches_to_lilypond(pitches) do
    [
      "<",
      Enum.map(pitches, &Satie.to_lilypond/1),
      ">"
    ]
    |> join(" ")
  end
end
