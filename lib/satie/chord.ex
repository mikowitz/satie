defmodule Satie.Chord do
  use Satie.Leaf, [:noteheads]

  @re ~r/^<s*(?<noteheads>([^?!]+[?!]?\s*)+)s*>(?<duration>(\\breve|\\longa|\\maxima|\d+)\.*)$/

  alias Satie.{Duration, Notehead}

  def new(chord) when is_bitstring(chord) do
    case Regex.named_captures(@re, chord) do
      %{"noteheads" => noteheads, "duration" => duration} ->
        noteheads = noteheads |> String.split(" ", trim: true) |> Enum.map(&Notehead.new/1)
        duration = Duration.new(duration)
        new(noteheads, duration)

      nil ->
        {:error, :chord_new, chord}
    end
  end

  def new(noteheads, %Duration{} = duration) do
    with :ok <- validate_noteheads(noteheads),
         true <- Duration.printable?(duration) do
      %__MODULE__{
        noteheads: noteheads,
        written_duration: duration
      }
    else
      _ -> {:error, :chord_new, {noteheads, duration}}
    end
  end

  defp validate_noteheads([]), do: :error
  defp validate_noteheads(noteheads), do: do_validate_noteheads(noteheads)

  defp do_validate_noteheads([]), do: :ok
  defp do_validate_noteheads([%Notehead{} | rest]), do: do_validate_noteheads(rest)
  defp do_validate_noteheads([_ | _]), do: :error

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

    def to_lilypond(%@for{noteheads: noteheads, written_duration: duration} = chord) do
      {attachments_before, attachments_after} = attachments_to_lilypond(chord)

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
