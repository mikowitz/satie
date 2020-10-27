defmodule Satie.Container do
  @moduledoc false

  defstruct [:music]

  def new(music) do
    %__MODULE__{
      music: List.wrap(music)
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Container do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Container{music: music}) do
    [
      "{",
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      "}"
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end
end
