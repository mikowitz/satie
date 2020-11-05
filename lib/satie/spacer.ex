defmodule Satie.Spacer do
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

defimpl Satie.ToLilypond, for: Satie.Spacer do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Spacer{written_duration: d, attachments: a, spanners: s}, _) do
    [
      "s" <> Satie.to_lilypond(d),
      attachments_to_lilypond(a),
      spanners_to_lilypond(s)
    ]
    |> join()
  end
end
