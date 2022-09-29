defmodule Satie.AccidentalTest do
  use ExUnit.Case, async: true

  alias Satie.Accidental

  describe inspect(&Accidental.new/1) do
    test "returns an error when the given string does not match the regex" do
      assert Accidental.new("stqs") == {:error, :accidental_new, "stqs"}
      assert Accidental.new("ssf") == {:error, :accidental_new, "ssf"}
      assert Accidental.new("natural") == {:error, :accidental_new, "natural"}
      assert Accidental.new("s+") == {:error, :accidental_new, "s+"}
    end

    test "regression" do
      File.read!("test/regression_data/accidental/new.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn [input, name, semitones] ->
        {semitones, ""} = Float.parse(semitones)

        assert Accidental.new(input) == %Accidental{
                 name: name,
                 semitones: semitones
               }
      end)
    end

    test "regression from numbers" do
      File.read!("test/regression_data/accidental/new_from_number.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn [input, name, semitones] ->
        {input, ""} = Float.parse(input)
        {semitones, ""} = Float.parse(semitones)

        assert Accidental.new(input) == %Accidental{
                 name: name,
                 semitones: semitones
               }
      end)
    end
  end
end
