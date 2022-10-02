defmodule Satie.IntervalTest do
  use ExUnit.Case, async: true

  import Satie.RegressionDataStreamer
  alias Satie.{Interval, IntervalClass}

  describe inspect(&Interval.new/1) do
    test "returns an error when the given string does not match the regex" do
      assert Interval.new("PerfectUnison") == {:error, :interval_new, "PerfectUnison"}
      assert Interval.new("MM22") == {:error, :interval_new, "MM22"}
    end

    test "returns an error when the interval size doesn't match the quality" do
      assert Interval.new("P16") == {:error, :interval_invalid_quality, {"P", 16}}
      assert Interval.new("m15") == {:error, :interval_invalid_quality, {"m", 15}}
    end

    test "returns an interval from a string" do
      assert Interval.new("M~9") == %Interval{
               interval_class: IntervalClass.new("M~2"),
               name: "+M~9",
               size: 9,
               polarity: 1,
               octaves: 1,
               quality: "M~",
               semitones: 13.5,
               staff_spaces: 8
             }
    end

    regression_test(:interval, :new, fn [
                                          input,
                                          ic_name,
                                          name,
                                          size,
                                          octaves,
                                          quality,
                                          polarity,
                                          semitones,
                                          staff_spaces
                                        ] ->
      {size, ""} = Integer.parse(size)
      {octaves, ""} = Integer.parse(octaves)
      {polarity, ""} = Integer.parse(polarity)
      {semitones, ""} = Float.parse(semitones)
      {staff_spaces, ""} = Integer.parse(staff_spaces)

      assert Interval.new(input) == %Interval{
               interval_class: IntervalClass.new(ic_name),
               name: name,
               size: size,
               polarity: polarity,
               octaves: octaves,
               quality: quality,
               semitones: semitones,
               staff_spaces: staff_spaces
             }
    end)
  end
end
