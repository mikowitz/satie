defmodule Satie.ChordTest do
  use ExUnit.Case, async: true

  alias Satie.{Chord, Duration, Pitch}
  doctest Chord

  setup do
    {:ok, d4: Pitch.new(2, 4), fs4: Pitch.new(6, 4), a4: Pitch.new(9, 4)}
  end

  describe ".new" do
    test "/1 accepts a lilypond string" do
      chord = Chord.new("<c' ef' a'>8")

      assert %Duration{numerator: 1, denominator: 8} == chord.written_duration
      assert [0, 3, 9] == chord.written_pitches |> Enum.map(& &1.pitch_class_index)
    end

    test "/2 accepts a list of pitches and a duration", context do
      chord = Chord.new([context.d4, context.fs4, context.a4], Duration.new(1, 8))

      assert [
               %Pitch{
                 pitch_class_index: 2,
                 octave: 4
               },
               %Pitch{
                 pitch_class_index: 6,
                 octave: 4
               },
               %Pitch{
                 pitch_class_index: 9,
                 octave: 4
               }
             ] == chord.written_pitches

      assert %Duration{numerator: 1, denominator: 8} == chord.written_duration
    end

    test "/2 accepts a single pitch and a duration", context do
      chord = Chord.new(context.d4, Duration.new(3, 16))

      assert [
               %Pitch{
                 pitch_class_index: 2,
                 octave: 4
               }
             ] == chord.written_pitches

      assert %Duration{
               numerator: 3,
               denominator: 16
             } == chord.written_duration
    end

    test "/2 throws an error if it receives an unassignable duration", context do
      assert_raise Satie.UnassignableDurationError, fn ->
        Chord.new([context.d4, context.fs4, context.a4], Duration.new(5, 1))
      end
    end

    test "/2 throws an error if it is passed a non-pitch", context do
      assert_raise Satie.UnassignablePitchError, fn ->
        Chord.new([context.d4, 7], Duration.new(1, 8))
      end
    end
  end

  describe "Satie.to_lilypond" do
    test "returns a lilypond representation of the chord" do
      chord =
        Chord.new(
          [Pitch.new(7, 4), Pitch.new(11, 4), Pitch.new(2, 5)],
          Duration.new(1, 16)
        )

      assert Satie.to_lilypond(chord) === "< g' b' d'' >16"
    end
  end
end
