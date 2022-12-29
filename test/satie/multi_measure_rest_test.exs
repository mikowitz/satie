defmodule Satie.MultiMeasureRestTest do
  use ExUnit.Case, async: true

  alias Satie.{MultiMeasureRest, Multiplier, TimeSignature}

  describe inspect(&MultiMeasureRest.new/1) do
    test "can parse a multi-measure rest from a string" do
      assert MultiMeasureRest.new("R1*4/4*17") == %MultiMeasureRest{
               multiplier: %Multiplier{
                 numerator: 1,
                 denominator: 1
               },
               measures: 17
             }
    end

    test "can parse without the leading `R1`" do
      assert MultiMeasureRest.new("3/4*10") == %MultiMeasureRest{
               multiplier: %Multiplier{
                 numerator: 3,
                 denominator: 4
               },
               measures: 10
             }
    end

    test "retutrns an error for an unparseable string" do
      assert MultiMeasureRest.new("17*10") == {:error, :multi_measure_rest_new, "17*10"}
    end
  end

  describe inspect(&MultiMeasureRest.new/2) do
    test "creates a multi-measure rest from a multiplier and measure count" do
      assert MultiMeasureRest.new(Multiplier.new(3, 4), 4) == %MultiMeasureRest{
               multiplier: %Multiplier{
                 numerator: 3,
                 denominator: 4
               },
               measures: 4
             }
    end

    test "creates a multi-measure rest from a multiplier-equivalent and measure count" do
      assert MultiMeasureRest.new({1, 4}, 7) == %MultiMeasureRest{
               multiplier: %Multiplier{
                 numerator: 1,
                 denominator: 4
               },
               measures: 7
             }
    end

    test "returns an error if either argument is not the required type" do
      assert MultiMeasureRest.new({3, 4}, 7.5) ==
               {:error, :multi_measure_rest_new, {{3, 4}, 7.5}}

      assert MultiMeasureRest.new(TimeSignature.new("3/4"), 7) ==
               {:error, :multi_measure_rest_new, {TimeSignature.new(3, 4), 7}}
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a multi-measure rest" do
      assert MultiMeasureRest.new(Multiplier.new("3/4"), 8) |> to_string() == "R1 * 3/4 * 8"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a multi-measure rest formatted for IEx" do
      assert MultiMeasureRest.new(Multiplier.new("7/8"), 3) |> inspect() ==
               "#Satie.MultiMeasureRest<7/8 * 3>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a multi-measure rest" do
      assert MultiMeasureRest.new(Multiplier.new(11, 8), 17) |> Satie.to_lilypond() ==
               "R1 * 11/8 * 17"
    end
  end
end
