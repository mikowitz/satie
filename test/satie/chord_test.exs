defmodule Satie.ChordTest do
  use ExUnit.Case, async: true

  alias Satie.{Chord, Duration, Interval, Notehead, Pitch}

  describe inspect(&Chord.new/1) do
    test "returns a chord from a parseable string" do
      assert Chord.new("<c'? e'! g'>4") == %Chord{
               noteheads: [
                 Notehead.new("c'?"),
                 Notehead.new("e'!"),
                 Notehead.new("g'")
               ],
               written_duration: Duration.new(1, 4)
             }
    end

    test "returns an error for an unparseable string" do
      assert Chord.new("c' e' g' >8") == {:error, :chord_new, "c' e' g' >8"}
    end
  end

  describe inspect(&Chord.new/2) do
    test "returns a chord from a list of noteheads and a duration" do
      assert Chord.new(
               [
                 Notehead.new("c'"),
                 Notehead.new("e'"),
                 Notehead.new("g'")
               ],
               Duration.new(1, 4)
             ) == %Chord{
               noteheads: [
                 Notehead.new("c'"),
                 Notehead.new("e'"),
                 Notehead.new("g'")
               ],
               written_duration: Duration.new(1, 4)
             }
    end

    test "noteheads can be anything that can be parsed as a notehead" do
      assert Chord.new(
               [
                 "c'",
                 {"ef'", :forced},
                 Satie.Pitch.new("g'")
               ],
               Duration.new(1, 4)
             ) == %Chord{
               noteheads: [
                 Notehead.new("c'"),
                 Notehead.new("ef'!"),
                 Notehead.new("g'")
               ],
               written_duration: Duration.new(1, 4)
             }
    end

    test "durations can be anything that can be parsed as a duration" do
      for duration <- ["4", {1, 4}, Satie.Offset.new(1, 4)] do
        assert Chord.new(
                 [
                   Notehead.new("c'"),
                   Notehead.new("e'"),
                   Notehead.new("g'")
                 ],
                 duration
               ) == %Chord{
                 noteheads: [
                   Notehead.new("c'"),
                   Notehead.new("e'"),
                   Notehead.new("g'")
                 ],
                 written_duration: Duration.new(1, 4)
               }
      end
    end

    test "returns an error if the noteheads list is empty" do
      assert Chord.new([], Duration.new(1, 4)) == {:error, :chord_new, {[], Duration.new(1, 4)}}
    end

    test "returns a chord from any leaf type" do
      chord = Chord.new("<c'>8")
      note = Satie.Note.new("c'8")
      rest = Satie.Rest.new("r8")
      spacer = Satie.Spacer.new("s8")

      assert Chord.new(chord) == chord
      assert Chord.new(note) == chord
      assert Chord.new(rest) == chord
      assert Chord.new(spacer) == chord
    end

    test "returns an error when the duration is not assignable" do
      assert Chord.new([Notehead.new("c'")], Duration.new(1, 5)) ==
               {:error, :chord_new, {[Notehead.new("c'")], Duration.new(1, 5)}}
    end
  end

  describe inspect(&Chord.transpose/2) do
    test "transposes the full chord" do
      chord =
        Chord.new(
          [
            Notehead.new("c'"),
            Notehead.new("e'"),
            Notehead.new("g'")
          ],
          Duration.new(3, 8)
        )

      assert Chord.transpose(chord, Interval.new("M2")) ==
               Chord.new(
                 [
                   Notehead.new("d'"),
                   Notehead.new("fs'"),
                   Notehead.new("a'")
                 ],
                 Duration.new(3, 8)
               )
    end
  end

  describe inspect(&Chord.invert/2) do
    test "transposes the full chord" do
      chord =
        Chord.new(
          [
            Notehead.new("c'"),
            Notehead.new("e'"),
            Notehead.new("g'")
          ],
          Duration.new(3, 8)
        )

      assert Chord.invert(chord, Pitch.new("f'")) ==
               Chord.new(
                 [
                   Notehead.new("bf'"),
                   Notehead.new("gf'"),
                   Notehead.new("ef'")
                 ],
                 Duration.new(3, 8)
               )
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a chord" do
      assert Chord.new(
               [
                 Notehead.new("c'"),
                 Notehead.new("e'"),
                 Notehead.new("g'")
               ],
               Duration.new(3, 8)
             )
             |> to_string() == "< c' e' g' >4."
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a chord for IEx" do
      assert Chord.new(
               [
                 Notehead.new("c'"),
                 Notehead.new("e'"),
                 Notehead.new("g'")
               ],
               Duration.new(3, 8)
             )
             |> inspect() == "#Satie.Chord<< c' e' g' >4.>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a chord" do
      assert Chord.new(
               [
                 Notehead.new("c'"),
                 Notehead.new("e'"),
                 Notehead.new("g'")
               ],
               Duration.new(3, 8)
             )
             |> Satie.to_lilypond() ==
               """
               <
                 c'
                 e'
                 g'
               >4.
               """
               |> String.trim()
    end
  end
end
