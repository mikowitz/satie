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

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of the interval class" do
      assert IntervalClass.new("P1") |> to_string() == "P1"
      assert IntervalClass.new("m~3") |> to_string() == "+m~3"
      assert IntervalClass.new("-M+14") |> to_string() == "-M+7"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns the interval class formatted for IEx" do
      assert IntervalClass.new("P1") |> inspect() == "#Satie.IntervalClass<P1>"
      assert IntervalClass.new("-M~3") |> inspect() == "#Satie.IntervalClass<-M~3>"
      assert IntervalClass.new("M+14") |> inspect() == "#Satie.IntervalClass<+M+7>"
    end
  end
end
