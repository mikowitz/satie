defmodule Satie.PitchClassTest do
  use ExUnit.Case, async: true

  alias Satie.{Accidental, PitchClass}

  describe inspect(&PitchClass.new/1) do
    test "returns an error when the input is invalid" do
      assert PitchClass.new("qqs") == {:error, :pitch_class_new, "qqs"}
      assert PitchClass.new("atqsf") == {:error, :pitch_class_new, "atqsf"}
    end

    test "regression" do
      File.read!("test/regression_data/pitch_class/new.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn [input, name, semitones, accidental, pc_name] ->
        {semitones, ""} = Float.parse(semitones)

        assert PitchClass.new(input) == %PitchClass{
                 name: name,
                 accidental: Accidental.new(accidental),
                 semitones: semitones,
                 diatonic_pitch_class: pc_name
               }
      end)
    end
  end

  describe inspect(&PitchClass.alteration/1) do
    test "regression" do
      File.read!("test/regression_data/pitch_class/alteration.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn [input, alteration] ->
        {alteration, ""} = Float.parse(alteration)

        assert PitchClass.new(input) |> PitchClass.alteration() == alteration
      end)
    end
  end
end
