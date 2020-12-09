defmodule Satie.Rest do
  @moduledoc false

  use Satie.Leaf, [:written_duration]

  def new(%Duration{} = duration) do
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
end

defimpl Satie.ToLilypond, for: Satie.Rest do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Rest{written_duration: duration, attachments: a, spanners: s}, _) do
    [
      before_leaf_attachments_to_lilypond(a),
      "r" <> Satie.to_lilypond(duration),
      attachments_to_lilypond(a),
      spanners_to_lilypond(s)
    ]
    |> join()
  end
end
