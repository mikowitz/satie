defmodule Satie.NoteTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Interval, Note, Notehead, Pitch}

  describe inspect(&Note.new/1) do
    test "returns a note from a string" do
      assert Note.new("fqf?4") == %Note{
               written_duration: Duration.new(1, 4),
               notehead: %Notehead{
                 written_pitch: Pitch.new("fqf"),
                 accidental_display: :cautionary
               }
             }
    end

    test "returns an error when it's unparseable as a note" do
      assert Note.new("sss??4-") == {:error, :duration_new, "sss??4-"}
    end
  end

  describe inspect(&Note.new/2) do
    test "returns a note from a notehead and duration" do
      notehead = Notehead.new(Pitch.new("c"))
      duration = Duration.new(1, 4)

      assert Note.new(notehead, duration) == %Note{
               written_duration: duration,
               notehead: notehead
             }
    end

    test "returns an error tuple if the duration is not assignable" do
      notehead = Notehead.new(Pitch.new("c"))
      duration = Duration.new(5, 4)

      assert Note.new(notehead, duration) == {:error, :note_new, {:unassignable_duration, 5, 4}}
    end
  end

  describe inspect(&Note.transpose/2) do
    test "returns a note transposed by the given interval" do
      note = Note.new("c'4")

      assert Note.transpose(note, Interval.new("+A4")) ==
               Note.new("fs'4")

      assert Note.transpose(note, Interval.new("-P4")) ==
               Note.new("g4")
    end
  end

  describe inspect(&Note.invert/2) do
    test "returns a note inverted around the given axis" do
      note = Note.new("c'4")

      assert Note.invert(note, Pitch.new("g'")) ==
               Note.new("d''4")

      assert Note.invert(note, Pitch.new("a'")) ==
               Note.new("fs''4")

      assert Note.invert(note, Pitch.new("af")) ==
               Note.new("ff4")
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a note" do
      notehead = Notehead.new(Pitch.new("c'"))

      assert Note.new(notehead, Duration.new(3, 8)) |> to_string() == "c'4."
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a notehead formatted for IEx" do
      notehead = Notehead.new(Pitch.new("fs''"))

      assert Note.new(notehead, Duration.new(7, 8)) |> inspect() == "#Satie.Note<fs''2..>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a note" do
      notehead = Notehead.new(Pitch.new("cs"), accidental_display: :cautionary)

      assert Note.new(notehead, Duration.new(3, 8)) |> Satie.to_lilypond() == "cs?4."
    end
  end
end
