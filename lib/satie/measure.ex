defmodule Satie.Measure do
  @moduledoc false

  defstruct [:time_signature, :music]

  def new({_, _} = time_signature, music) do
    %__MODULE__{
      time_signature: time_signature,
      music: music
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Measure do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Measure{time_signature: {n, d}, music: music}) do
    [
      "{",
      indent("\\time #{n}/#{d}"),
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      indent("|"),
      "}"
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end
end
