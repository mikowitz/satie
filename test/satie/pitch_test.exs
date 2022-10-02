defmodule Satie.PitchTest do
  use ExUnit.Case, async: true

  import Satie.RegressionDataStreamer
  alias Satie.{Interval, Pitch, PitchClass}

  describe inspect(&Pitch.new/1) do
    test "returns an error for invalid input" do
      assert Pitch.new("cqs;") == {:error, :pitch_new, "cqs;"}
      assert Pitch.new("ccs'") == {:error, :pitch_new, "ccs'"}
    end

    test "returns a pitch from a string" do
      assert Pitch.new("cqs") == %Pitch{
               name: "cqs",
               pitch_class: PitchClass.new("cqs"),
               semitones: -11.5,
               octave: 3
             }

      assert Pitch.new("d,") == %Pitch{
               name: "d,",
               pitch_class: PitchClass.new("d"),
               semitones: -22,
               octave: 2
             }
    end

    regression_test(:pitch, :new, fn [input, name, pc_name, semitones, octave] ->
      {semitones, ""} = Float.parse(semitones)
      {octave, ""} = Integer.parse(octave)

      assert Pitch.new(input) == %Pitch{
               name: name,
               pitch_class: PitchClass.new(pc_name),
               semitones: semitones,
               octave: octave
             }
    end)
  end

  describe inspect(&Pitch.to_interval/1) do
    test "converts a pitch to an interval" do
      assert Pitch.new("c") |> Pitch.to_interval() == Interval.new("-P8")
      assert Pitch.new("cqs'") |> Pitch.to_interval() == Interval.new("+P+1")
    end

    regression_test(:pitch, :to_interval, fn [input, interval_name] ->
      assert Pitch.new(input) |> Pitch.to_interval() == Interval.new(interval_name)
    end)
  end

  describe inspect(&Pitch.add/2) do
    test "correctly adds two pitches" do
      c3 = Pitch.new("c")
      d4 = Pitch.new("d'")
      f5 = Pitch.new("f''")

      assert Pitch.add(c3, c3) == Pitch.new("c,")
      assert Pitch.add(c3, d4) == Pitch.new("d")
      assert Pitch.add(c3, f5) == Pitch.new("f'")
      assert Pitch.add(d4, d4) == Pitch.new("e'")
      assert Pitch.add(d4, f5) == Pitch.new("g''")
      assert Pitch.add(f5, f5) == Pitch.new("bf'''")
    end

    regression_test(:pitch, :add, fn [input1, input2, expected] ->
      p1 = Pitch.new(input1)
      p2 = Pitch.new(input2)
      sum = Pitch.add(p1, p2)

      assert is_struct(sum, Pitch)
      assert sum.name == expected
    end)
  end

  describe inspect(&Pitch.subtract/2) do
    test "returns the interval between the first and the second pitch" do
      c3 = Pitch.new("c")
      d4 = Pitch.new("d'")
      f5 = Pitch.new("f''")

      assert Pitch.subtract(c3, c3) == Interval.new("P1")
      assert Pitch.subtract(c3, d4) == Interval.new("+M9")
      assert Pitch.subtract(c3, f5) == Interval.new("+P18")
      assert Pitch.subtract(d4, c3) == Interval.new("-M9")
      assert Pitch.subtract(d4, d4) == Interval.new("P1")
      assert Pitch.subtract(d4, f5) == Interval.new("+m10")
      assert Pitch.subtract(f5, c3) == Interval.new("-P18")
      assert Pitch.subtract(f5, d4) == Interval.new("-m10")
      assert Pitch.subtract(f5, f5) == Interval.new("+P1")
    end

    regression_test(:pitch, :subtract, fn [input1, input2, expected] ->
      p1 = Pitch.new(input1)
      p2 = Pitch.new(input2)
      diff = Pitch.subtract(p1, p2)

      assert is_struct(diff, Interval)
      assert diff.name == expected
    end)
  end
end
