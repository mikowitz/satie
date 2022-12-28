defmodule Satie.TimeSignatureTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Rest, TimeSignature}

  describe_function &TimeSignature.new/1 do
    test "parses a valid string into a time signature" do
      assert TimeSignature.new("\\time 3/16") == %TimeSignature{
               numerator: 3,
               denominator: 16,
               components: [
                 before: ["\\time 3/16"]
               ]
             }
    end

    test "doesn't require the `\\time` at the beginning" do
      assert TimeSignature.new("7/16") == %TimeSignature{
               numerator: 7,
               denominator: 16,
               components: [
                 before: ["\\time 7/16"]
               ]
             }
    end

    test "returns an error for an unparseable string" do
      assert TimeSignature.new("\\term 4/5") == {:error, :time_signature_new, "\\term 4/5"}
      assert TimeSignature.new("\\time 4.7/5") == {:error, :time_signature_new, "\\time 4.7/5"}
      assert TimeSignature.new("\\time 4-5") == {:error, :time_signature_new, "\\time 4-5"}
    end
  end

  describe_function &TimeSignature.new/2 do
    test "creates a new time signature from two integers" do
      assert TimeSignature.new(3, 4) == %TimeSignature{
               numerator: 3,
               denominator: 4,
               components: [
                 before: ["\\time 3/4"]
               ]
             }
    end

    test "doesn't reduce a fraction" do
      assert TimeSignature.new(4, 8) == %TimeSignature{
               numerator: 4,
               denominator: 8,
               components: [
                 before: ["\\time 4/8"]
               ]
             }
    end

    test "returns an error if either argument is not an integer" do
      assert TimeSignature.new(1.5, 4) == {:error, :time_signature_new, {1.5, 4}}

      assert TimeSignature.new(4, "4") == {:error, :time_signature_new, {4, "4"}}
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a time signature formatted for IEx" do
      assert TimeSignature.new("\\time 4/8") |> inspect == "#Satie.TimeSignature<4/8>"
    end
  end

  describe "attaching a timesignature to a rest" do
    test "returns the correct lilypond" do
      rest =
        Rest.new("4")
        |> Satie.attach(TimeSignature.new("3/4"))

      assert Satie.to_lilypond(rest) ==
               """
               \\time 3/4
               r4
               """
               |> String.trim()
    end
  end
end
