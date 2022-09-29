defmodule Satie.IntervalTest do
  use ExUnit.Case, async: true

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

    @tag :focus
    test "regression" do
      File.read!("test/regression_data/interval/new.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(fn [
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
end
