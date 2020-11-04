defmodule Satie.Container do
  @moduledoc false

  use Satie.Tree

  def new(music) do
    %__MODULE__{
      music: List.wrap(music),
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Container do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Container{music: music}, _) do
    [
      "{",
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      "}"
    ]
    |> join()
  end
end
