defmodule Satie.PitchClassTest do
  use ExUnit.Case, async: true

  import Satie.RegressionDataStreamer
  alias Satie.{Accidental, PitchClass}

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

      assert PitchClass.new("d") == %PitchClass{
               name: "d",
               accidental: Accidental.new(""),
               semitones: 2.0,
               diatonic_pitch_class: "d"
             }
    end

    test "returns a PitchClass from a PitchClass" do
      pitch_class = PitchClass.new("c")

      assert PitchClass.new(pitch_class) == pitch_class
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

  describe inspect(&PitchClass.new/2) do
    test "returns a pitch class from a diatonic pitch class and accidental-equivalent" do
      assert PitchClass.new("b", "qf") == %PitchClass{
               name: "bqf",
               accidental: Accidental.new("~"),
               semitones: 10.5,
               diatonic_pitch_class: "b"
             }

      assert PitchClass.new("c", Accidental.new("+")) == %PitchClass{
               name: "cqs",
               accidental: Accidental.new("+"),
               semitones: 0.5,
               diatonic_pitch_class: "c"
             }
    end
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

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of the pitch class" do
      assert PitchClass.new("c+") |> to_string() == "cqs"
      assert PitchClass.new("fff") |> to_string() == "fff"
      assert PitchClass.new("bssqs") |> to_string() == "bssqs"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns the pitch class formatted for IEx" do
      assert PitchClass.new("c~") |> inspect() == "#Satie.PitchClass<cqf>"
      assert PitchClass.new("asqs") |> inspect() == "#Satie.PitchClass<atqs>"
      assert PitchClass.new("dtqf") |> inspect() == "#Satie.PitchClass<dtqf>"
    end
  end
end
