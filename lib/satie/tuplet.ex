defmodule Satie.Tuplet do
  @moduledoc false

  use Satie.Tree, [:multiplier]

  def new({_, _} = multiplier, music) do
    %__MODULE__{
      multiplier: multiplier,
      music: List.wrap(music),
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Tuplet do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Tuplet{multiplier: {n, d}, music: music}, _) do
    [
      "\\tuplet #{d}/#{n} {",
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      "}"
    ]
    |> join()
  end
end
