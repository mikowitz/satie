defmodule Satie.Measure do
  @moduledoc false

  use Satie.Tree, [:time_signature]

  def new({_, _} = time_signature, music) do
    %__MODULE__{
      time_signature: time_signature,
      music: music,
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Measure do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Measure{time_signature: {n, d}, music: music}, _) do
    [
      "{",
      indent("\\time #{n}/#{d}"),
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      indent("|"),
      "}"
    ]
    |> join()
  end
end
