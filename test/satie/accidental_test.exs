defmodule Satie.AccidentalTest do
  use ExUnit.Case, async: true

  import Satie.RegressionDataStreamer
  alias Satie.Accidental

  describe inspect(&Accidental.new/1) do
    test "returns an error when the given string does not match the regex" do
      assert Accidental.new("stqs") == {:error, :accidental_new, "stqs"}
      assert Accidental.new("ssf") == {:error, :accidental_new, "ssf"}
      assert Accidental.new("natural") == {:error, :accidental_new, "natural"}
      assert Accidental.new("s+") == {:error, :accidental_new, "s+"}
    end

    test "returns an accidental from a string" do
      assert Accidental.new("") == %Accidental{
               name: "natural",
               semitones: 0.0
             }

      assert Accidental.new("tqf") == %Accidental{
               name: "tqf",
               semitones: -1.5
             }
    end

    test "returns an accidental from a number" do
      assert Accidental.new(3.5) == %Accidental{
               name: "sssqs",
               semitones: 3.5
             }
    end

    regression_test(:accidental, :new, fn [input, name, semitones] ->
      {semitones, ""} = Float.parse(semitones)

      assert Accidental.new(input) == %Accidental{
               name: name,
               semitones: semitones
             }
    end)

    regression_test(:accidental, :new_from_number, fn [input, name, semitones] ->
      {input, ""} = Float.parse(input)
      {semitones, ""} = Float.parse(semitones)

      assert Accidental.new(input) == %Accidental{
               name: name,
               semitones: semitones
             }
    end)
  end
end
