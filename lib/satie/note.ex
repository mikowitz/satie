defmodule Satie.Note do
  @moduledoc false

  use Satie.Leaf, [:written_pitch, :written_duration]

  alias Satie.Pitch

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
end

defimpl Satie.ToLilypond, for: Satie.Note do
  import Satie.Lilypond.Helpers

  def to_lilypond(
        %Satie.Note{written_pitch: p, written_duration: d, attachments: a, spanners: s},
        _
      ) do
    [
      before_leaf_attachments_to_lilypond(a),
      Satie.to_lilypond(p) <> Satie.to_lilypond(d),
      attachments_to_lilypond(a),
      spanners_to_lilypond(s)
    ]
    |> join()
  end
end
