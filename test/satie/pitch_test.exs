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

  describe inspect(&Pitch.new/2) do
    test "returns a pitch from a pitch class string and octave number" do
      assert Pitch.new("d", 2) == %Pitch{
               name: "d,",
               pitch_class: PitchClass.new("d"),
               semitones: -22,
               octave: 2
             }
    end

    test "returns a pitch from a pitch class string and octave string" do
      assert Pitch.new("d", "'") == %Pitch{
               name: "d'",
               pitch_class: PitchClass.new("d"),
               semitones: 2,
               octave: 4
             }
    end

    test "returns a pitch from a pitch class and octave number" do
      assert Pitch.new(PitchClass.new("d"), 3) == %Pitch{
               name: "d",
               pitch_class: PitchClass.new("d"),
               semitones: -10,
               octave: 3
             }
    end

    test "returns a pitch from a pitch class and octave string" do
      assert Pitch.new(PitchClass.new("d"), ",") == %Pitch{
               name: "d,",
               pitch_class: PitchClass.new("d"),
               semitones: -22,
               octave: 2
             }
    end
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

  describe inspect(&Pitch.transpose/2) do
    test "transposes a pitch by the given interval" do
      assert Pitch.new("c") |> Pitch.transpose(Interval.new("m3")) == Pitch.new("ef")
      assert Pitch.new("c") |> Pitch.transpose(Interval.new("-m3")) == Pitch.new("a,")
    end

    regression_test(:pitch, :transpose, fn [input1, input2, expected] ->
      pitch = Pitch.new(input1)
      interval = Interval.new(input2)
      pitch2 = Pitch.transpose(pitch, interval)

      assert pitch2 == Pitch.new(expected)
    end)
  end

  describe inspect(&Pitch.invert/2) do
    test "inverts a pitch around another pitch serving as the axis" do
      c4 = Pitch.new("c'")
      bf3 = Pitch.new("bf")
      b4 = Pitch.new("b'")

      assert Pitch.invert(c4, bf3) == Pitch.new("af")
      assert Pitch.invert(bf3, c4) == Pitch.new("d'")
      assert Pitch.invert(b4, c4) == Pitch.new("df")
    end

    regression_test(:pitch, :invert, fn [input1, input2, expected] ->
      pitch = Pitch.new(input1)
      pitch2 = Pitch.new(input2)
      inverted = Pitch.invert(pitch, pitch2)

      assert inverted == Pitch.new(expected)
    end)
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of the pitch" do
      assert Pitch.new("c+'") |> to_string() == "cqs'"
      assert Pitch.new("fff,,") |> to_string() == "fff,,"
      assert Pitch.new("bsqs") |> to_string() == "btqs"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns the pitch formatted for IEx" do
      assert Pitch.new("c~,") |> inspect() == "#Satie.Pitch<cqf,>"
      assert Pitch.new("asqs'") |> inspect() == "#Satie.Pitch<atqs'>"
      assert Pitch.new("dqf") |> inspect() == "#Satie.Pitch<dqf>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns a lilypond representation of the pitch" do
      assert Pitch.new("c''") |> Satie.to_lilypond() == "c''"
      assert Pitch.new("c+") |> Satie.to_lilypond() == "cqs"
      assert Pitch.new("ftqs,") |> Satie.to_lilypond() == "ftqs,"
    end
  end
end
