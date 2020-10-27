defmodule Satie.Tuplet do
  @moduledoc false

  defstruct [:multiplier, :music]

  def new({_, _} = multiplier, music) do
    %__MODULE__{
      multiplier: multiplier,
      music: List.wrap(music)
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Tuplet do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Tuplet{multiplier: {n, d}, music: music}) do
    [
      "\\tuplet #{d}/#{n} {",
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      "}"
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end
end
