defmodule Satie.ChordTest do
  use ExUnit.Case

  alias Satie.{Chord, Duration, Pitch}
  doctest Chord

  @d4 Pitch.new(2, 4)
  @fs4 Pitch.new(6, 4)
  @a4 Pitch.new(9, 4)

  describe ".new" do
    test "/2 accepts a list of pitches and a duration" do
      assert Chord.new([@d4, @fs4, @a4], Duration.new(1, 8)) == %Chord{
               written_pitches: [
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
               ],
               written_duration: %Duration{
                 numerator: 1,
                 denominator: 8
               }
             }
    end

    test "/2 accepts a single pitch and a duration" do
      assert Chord.new(@d4, Duration.new(3, 16)) == %Chord{
               written_pitches: [
                 %Pitch{
                   pitch_class_index: 2,
                   octave: 4
                 }
               ],
               written_duration: %Duration{
                 numerator: 3,
                 denominator: 16
               }
             }
    end

    test "/2 throws an error if it receives an unassignable duration" do
      assert_raise Satie.UnassignableDurationError, fn ->
        Chord.new([@d4, @fs4, @a4], Duration.new(5, 1))
      end
    end

    test "/2 throws an error if it is passed a non-pitch" do
      assert_raise Satie.UnassignablePitchError, fn ->
        Chord.new([@d4, 7], Duration.new(1, 8))
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
