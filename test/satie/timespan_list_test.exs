defmodule Satie.TimespanListTest do
  use ExUnit.Case, async: true

  alias Satie.{Timespan, TimespanList}

  doctest TimespanList

  describe inspect(&TimespanList.sorted_into_non_overlapping_sublists/1) do
    test "divides a list of timespans into sublists, each of which contains only non-overlapping timespans" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(-2, 8),
          Timespan.new(15, 20),
          Timespan.new(24, 30)
        ])

      assert TimespanList.sorted_into_non_overlapping_sublists(timespan_list) == [
               [Timespan.new(0, 16), Timespan.new(24, 30)],
               [Timespan.new(5, 12), Timespan.new(15, 20)],
               [Timespan.new(-2, 8)]
             ]
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correctly formatted Lilypond markup for the list" do
      expected = File.read!("test/files/timespan_list.ly") |> String.trim()

      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(-2, 8),
          Timespan.new(15, 20),
          Timespan.new(24, 30)
        ])

      assert Satie.to_lilypond(timespan_list) == expected
    end
  end
end
