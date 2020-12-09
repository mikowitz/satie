defmodule Satie.PianoStaff do
  @moduledoc false

  use Satie.Tree, [:name]

  def new(music, opts \\ []) do
    %__MODULE__{
      music: List.wrap(music),
      name: opts[:name],
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.PianoStaff do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.PianoStaff{name: name, music: music}, _) do
    [
      opening_bracket(name),
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      ">>"
    ]
    |> join()
  end

  ## PRIVATE

  defp opening_bracket(nil), do: "\\new PianoStaff <<"

  defp opening_bracket(name) do
    ~s(\\context PianoStaff = "#{name}" <<)
  end
end
