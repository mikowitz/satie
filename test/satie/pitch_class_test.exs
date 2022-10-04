defmodule Satie.PitchClassTest do
  use ExUnit.Case, async: true

  import Satie.RegressionDataStreamer
  alias Satie.{Accidental, IntervalClass, PitchClass}

  describe inspect(&PitchClass.new/1) do
    test "returns an error when the input is invalid" do
      assert PitchClass.new("qqs") == {:error, :pitch_class_new, "qqs"}
      assert PitchClass.new("atqsf") == {:error, :pitch_class_new, "atqsf"}
    end

    test "returns a PitchClass from a string" do
      assert PitchClass.new("bqf") == %PitchClass{
               name: "bqf",
               accidental: Accidental.new("~"),
               semitones: 10.5,
               diatonic_pitch_class: "b"
             }
    end

    regression_test(:pitch_class, :new, fn [input, name, semitones, accidental, pc_name] ->
      {semitones, ""} = Float.parse(semitones)

      assert PitchClass.new(input) == %PitchClass{
               name: name,
               accidental: Accidental.new(accidental),
               semitones: semitones,
               diatonic_pitch_class: pc_name
             }
    end)
  end

  describe inspect(&PitchClass.alteration/1) do
    test "returns the accidental's semitones" do
      assert PitchClass.new("d") |> PitchClass.alteration() == 0
      assert PitchClass.new("eqf") |> PitchClass.alteration() == -0.5
      assert PitchClass.new("ftqs") |> PitchClass.alteration() == 1.5
    end

    regression_test(:pitch_class, :alteration, fn [input, alteration] ->
      {alteration, ""} = Float.parse(alteration)

      assert PitchClass.new(input) |> PitchClass.alteration() == alteration
    end)
  end

  describe inspect(&PitchClass.add/2) do
    test "returns the sum of two pitch classes" do
      c = PitchClass.new("c")
      d = PitchClass.new("d")
      b = PitchClass.new("b")

      assert PitchClass.add(c, d) == d
      assert PitchClass.add(b, d) == PitchClass.new("cs")
    end

    regression_test(:pitch_class, :add, fn [input1, input2, expected] ->
      pc1 = PitchClass.new(input1)
      pc2 = PitchClass.new(input2)
      sum = PitchClass.add(pc1, pc2)

      assert sum.name == expected
    end)
  end

  # describe inspect(&PitchClass.subtract/2) do
  #   test "returns the interval between two pitch classes" do
  #     c = PitchClass.new("c")
  #     d = PitchClass.new("d")
  #     b = PitchClass.new("b")
  #
  #     assert PitchClass.subtract(c, d) == IntervalClass.new("M2")
  #     assert PitchClass.subtract(b, d) == IntervalClass.new("m3")
  #   end
  #
  #   regression_test(:pitch_class, :add, fn [input1, input2, expected] ->
  #     pc1 = PitchClass.new(input1)
  #     pc2 = PitchClass.new(input2)
  #     interval = PitchClass.subtract(pc1, pc2)
  #
  #     assert interval.name == expected
  #   end)
  # end
end
