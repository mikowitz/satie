defmodule Satie.IntervalClassTest do
  use ExUnit.Case, async: true

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

    test "regression" do
      File.read!("test/regression_data/interval_class/new.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(fn [input, name, size, quality, polarity] ->
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
  end
end
