defmodule Satie.TimeSignatureTest do
  use ExUnit.Case, async: true

  alias Satie.TimeSignature

  describe inspect(&TimeSignature.new/1) do
    test "parses a valid string into a time signature" do
      assert TimeSignature.new("\\time 3/16") == %TimeSignature{
               numerator: 3,
               denominator: 16
             }
    end

    test "doesn't require the `\\time` at the beginning" do
      assert TimeSignature.new("7/16") == %TimeSignature{
               numerator: 7,
               denominator: 16
             }
    end

    test "returns an error for an unparseable string" do
      assert TimeSignature.new("\\term 4/5") == {:error, :time_signature_new, "\\term 4/5"}
      assert TimeSignature.new("\\time 4.7/5") == {:error, :time_signature_new, "\\time 4.7/5"}
      assert TimeSignature.new("\\time 4-5") == {:error, :time_signature_new, "\\time 4-5"}
    end
  end

  describe inspect(&TimeSignature.new/2) do
    test "creates a new time signature from two integers" do
      assert TimeSignature.new(3, 4) == %TimeSignature{
               numerator: 3,
               denominator: 4
             }
    end

    test "doesn't reduce a fraction" do
      assert TimeSignature.new(4, 8) == %TimeSignature{
               numerator: 4,
               denominator: 8
             }
    end

    test "returns an error if either argument is not an integer" do
      assert TimeSignature.new(1.5, 4) == {:error, :time_signature_new, {1.5, 4}}

      assert TimeSignature.new(4, "4") == {:error, :time_signature_new, {4, "4"}}
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a time signature" do
      assert TimeSignature.new(3, 8) |> to_string == "\\time 3/8"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a time signature formatted for IEx" do
      assert TimeSignature.new("\\time 4/8") |> inspect == "#Satie.TimeSignature<4/8>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a time signature" do
      assert TimeSignature.new(11, 8) |> Satie.to_lilypond() == "\\time 11/8"
    end
  end
end
