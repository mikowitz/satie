defmodule Satie.Score do
  @moduledoc false

  use Satie.Tree, [:name]

  def new(music, opts \\ []) do
    %__MODULE__{
      music: List.wrap(music),
      name: opts[:name]
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Score do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Score{name: name, music: music}, _) do
    [
      opening_bracket(name),
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      ">>"
    ]
    |> join()
  end

  ## PRIVATE

  defp opening_bracket(nil), do: "\\new Score <<"

  defp opening_bracket(name) do
    ~s(\\context Score = "#{name}" <<)
  end
end
