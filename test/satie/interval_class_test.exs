defmodule Satie.IntervalClassTest do
  use ExUnit.Case, async: true

  import Satie.RegressionDataStreamer
  alias Satie.IntervalClass

  describe inspect(&IntervalClass.new/1) do
    test "returns an error when the given string does not match the regex" do
      assert IntervalClass.new("~P-1") == {:error, :interval_class_new, "~P-1"}
      assert IntervalClass.new("MM2") == {:error, :interval_class_new, "MM2"}
    end

    test "returns an error when the interval class size doesn't match the quality" do
      assert IntervalClass.new("P2") == {:error, :interval_class_invalid_quality, {"P", 2}}
      assert IntervalClass.new("m4") == {:error, :interval_class_invalid_quality, {"m", 4}}
    end

    test "returns an interval class from a string" do
      assert IntervalClass.new("m2") == %IntervalClass{
               name: "+m2",
               size: 2,
               quality: "m",
               polarity: 1
             }

      assert IntervalClass.new("P+4") == %IntervalClass{
               name: "+P+4",
               size: 4,
               quality: "P+",
               polarity: 1
             }
    end

    regression_test(:interval_class, :new, fn [input, name, size, quality, polarity] ->
      {size, ""} = Integer.parse(size)
      {polarity, ""} = Integer.parse(polarity)

      assert IntervalClass.new(input) == %IntervalClass{
               name: name,
               size: size,
               quality: quality,
               polarity: polarity
             }
    end)
  end

  describe inspect(&IntervalClass.add/2) do
    test "returns the sum of two interval classes" do
      maj2 = IntervalClass.new("M2")
      m3 = IntervalClass.new("m3")
      np4 = IntervalClass.new("-P4")
      maj7 = IntervalClass.new("M7")

      assert IntervalClass.add(maj2, m3) == IntervalClass.new("P4")
      assert IntervalClass.add(maj7, np4) == IntervalClass.new("d5")
      assert IntervalClass.add(m3, maj7) == IntervalClass.new("M2")
      assert IntervalClass.add(maj2, np4) == IntervalClass.new("-m3")
    end

    regression_test(:interval_class, :add, fn [input1, input2, expected] ->
      ic1 = IntervalClass.new(input1)
      ic2 = IntervalClass.new(input2)
      sum = IntervalClass.add(ic1, ic2)

      assert sum.name == expected
    end)
  end

  # describe inspect(&IntervalClass.subtract/2) do
  #   test "returns the interval class between two interval classes" do
  #     maj2 = IntervalClass.new("M2")
  #     m3 = IntervalClass.new("m3")
  #     np4 = IntervalClass.new("-P4")
  #     maj7 = IntervalClass.new("M7")
  #
  #     assert IntervalClass.subtract(maj2, m3) == IntervalClass.new("-m2")
  #     assert IntervalClass.subtract(maj7, np4) == IntervalClass.new("M3")
  #   end
  #
  #   regression_test(:interval_class, :subtract, fn [input1, input2, expected] ->
  #     ic1 = IntervalClass.new(input1)
  #     ic2 = IntervalClass.new(input2)
  #     diff = IntervalClass.subtract(ic1, ic2)
  #
  #     assert diff.name == expected
  #   end)
  # end
end
