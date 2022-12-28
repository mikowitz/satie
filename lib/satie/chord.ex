defmodule Satie.Chord do
  @moduledoc """
  Models a musical chord consisting of one or more noteheads
  """
  use Satie.Leaf, [:noteheads]

  def new(chord), do: Satie.ToChord.from(chord)

  def new(noteheads, duration), do: new({noteheads, duration})

  use Satie.Transposable, :noteheads

  defimpl String.Chars do
    def to_string(%@for{noteheads: noteheads, written_duration: duration}) do
      [
        "<",
        Enum.map(noteheads, &Satie.to_lilypond/1),
        ">#{Satie.to_lilypond(duration)}"
      ]
      |> List.flatten()
      |> Enum.join(" ")
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = chord, _opts) do
      concat([
        "#Satie.Chord<",
        to_string(chord),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{noteheads: noteheads, written_duration: duration} = chord, _opts) do
      %{before: attachments_before, after: attachments_after} = attachments_to_lilypond(chord)

      [
        attachments_before,
        "<",
        Enum.map(noteheads, &"  #{Satie.to_lilypond(&1)}"),
        ">#{Satie.to_lilypond(duration)}",
        Enum.map(attachments_after, &indent/1)
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end
  end
end
