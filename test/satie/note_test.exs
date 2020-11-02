defmodule Satie.NoteTest do
  use ExUnit.Case, async: true

  alias Satie.{Articulation, Duration, Note, Pitch}
  doctest Note

  setup do
    {:ok, pitch: Pitch.new(2, 3)}
  end

  describe ".new" do
    test "/2 accepts a pitch and a duration", context do
      duration = Duration.new(7, 16)
      note = Note.new(context.pitch, duration)

      assert %Pitch{pitch_class_index: 2, octave: 3} == note.written_pitch
      assert %Duration{numerator: 7, denominator: 16} === note.written_duration
    end

    test "/2 throws an error if it receives an unassignable duration", context do
      assert_raise Satie.UnassignableDurationError, fn ->
        Note.new(context.pitch, Duration.new(5, 16))
      end
    end
  end

  describe "Satie.ToLilypond" do
    test ".to_lilypond/1 returns the correct lilypond representation of the note" do
      assert Note.new(Pitch.new(3, 4), Duration.new(7, 32)) |> Satie.to_lilypond() == "ef'8.."
    end

    test "includes attachments" do
      note = Note.new(Pitch.new(2, 3), Duration.new(3, 4))
      note = Satie.attach(note, Articulation.new("accent"))

      assert Satie.to_lilypond(note) ===
               """
               d2.
                 \\accent
               """
               |> String.trim()
    end
  end
end
