defmodule Satie.Lilypond.ParserTest do
  use ExUnit.Case, async: true

  alias Satie.Lilypond.Parser
  alias Satie.{Chord, Container, Duration, Measure, Note, Pitch, Rest, Spacer, Tuplet}

  describe "simple cases" do
    test "a single rest" do
      {:ok, %Rest{} = rest} = Parser.parse("r4")

      assert rest.written_duration == Duration.new(1, 4)
    end

    test "a single spacer" do
      {:ok, %Spacer{} = rest} = Parser.parse("s2..")

      assert rest.written_duration == Duration.new(7, 8)
    end

    test "a simple note" do
      {:ok, %Note{} = note} = Parser.parse("c'16")

      assert note.written_duration == Duration.new(1, 16)
      assert note.written_pitch == Pitch.new(0, 4)
    end

    test "an accidental note" do
      {:ok, %Note{} = note} = Parser.parse("ef,,4")

      assert note.written_duration == Duration.new(1, 4)
      assert note.written_pitch == Pitch.new(3, 1)
    end

    test "with no octave" do
      {:ok, %Note{} = note} = Parser.parse("ef4")

      assert note.written_duration == Duration.new(1, 4)
      assert note.written_pitch == Pitch.new(3, 3)
    end

    test "with whitespace" do
      {:ok, %Note{} = note} = Parser.parse("\n\t  ef4  ")

      assert note.written_duration == Duration.new(1, 4)
      assert note.written_pitch == Pitch.new(3, 3)
    end

    test "simple chord" do
      {:ok, %Chord{} = chord} = Parser.parse("< c' e' g' >4")

      assert chord.written_duration == Duration.new(1, 4)

      assert chord.written_pitches == [
               Pitch.new(0, 4),
               Pitch.new(4, 4),
               Pitch.new(7, 4)
             ]
    end
  end

  describe "trees" do
    test "an empty container" do
      {:ok, %Container{} = container} = Parser.parse("{ }")

      assert container.music == []
    end

    test "a container with a single note" do
      {:ok, %Container{} = container} = Parser.parse("{ c4 }")

      [n] = container.music
      assert n.written_duration == Duration.new(1, 4)
      assert n.written_pitch == Pitch.new(0, 3)
    end

    test "with multiple leaves" do
      {:ok, %Container{} = container} = Parser.parse("{ c'4 d4. r8 ef,16... }")

      [c, d, r, e] = container.music
      assert c.written_duration == Duration.new(1, 4)
      assert c.written_pitch == Pitch.new(0, 4)

      assert d.written_duration == Duration.new(3, 8)
      assert d.written_pitch == Pitch.new(2, 3)

      assert r.written_duration == Duration.new(1, 8)

      assert e.written_duration == Duration.new(15, 128)
      assert e.written_pitch == Pitch.new(3, 2)
    end

    test "nested containers" do
      {:ok, %Container{} = container} = Parser.parse("{ c'4 { \\time 3/4 d'4 e'4 f'4 } d'4 }")

      [_c, %Measure{} = t, _d] = container.music

      [_d, _e, f] = t.music

      assert f.written_duration == Duration.new(1, 4)
    end

    test "tuplets" do
      {:ok, %Tuplet{} = tuplet} =
        Parser.parse("\\tuplet 3/2 { c'4 d'4 \\tuplet 3/2 { e'8 f'8 g'8 } }")

      assert tuplet.multiplier == {2, 3}
      [c, d, t2] = tuplet.music
      [e, f, g] = t2.music

      assert c.written_pitch == Pitch.new(0, 4)
      assert d.written_pitch == Pitch.new(2, 4)
      assert e.written_pitch == Pitch.new(4, 4)
      assert f.written_pitch == Pitch.new(5, 4)
      assert g.written_pitch == Pitch.new(7, 4)
      assert c.written_duration == Duration.new(1, 4)
      assert d.written_duration == Duration.new(1, 4)
      assert e.written_duration == Duration.new(1, 8)
      assert f.written_duration == Duration.new(1, 8)
      assert g.written_duration == Duration.new(1, 8)
    end

    test "measures cannot be nested" do
      assert_raise MatchError, fn ->
        Parser.parse("{ \\time 2/4 c'4 { \\time 2/8 d'8 ef'8 } }")
      end
    end
  end
end
