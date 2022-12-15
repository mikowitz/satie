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

  describe inspect(&TimespanList.well_formed?/1) do
    test "returns true if all timespans are well formed" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(-2, 8)
        ])

      assert TimespanList.well_formed?(timespan_list)
    end

    test "returns false if any timespans are not well formed" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(8, -2)
        ])

      refute TimespanList.well_formed?(timespan_list)
    end
  end

  describe inspect(&TimespanList.all_non_overlapping?/1) do
    test "returns true if no timespans overlap with any others" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(16, 20),
          Timespan.new(25, 30)
        ])

      assert TimespanList.all_non_overlapping?(timespan_list)
    end

    test "returns false if any timespans overlap" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(8, -2)
        ])

      refute TimespanList.all_non_overlapping?(timespan_list)
    end
  end

  describe inspect(&TimespanList.contiguous?/1) do
    test "returns true if all timespans are contiguous" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(16, 20),
          Timespan.new(20, 30)
        ])

      assert TimespanList.contiguous?(timespan_list)
    end

    test "returns false if any timespan is not contiguous to another" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(16, 20),
          Timespan.new(25, 30)
        ])

      refute TimespanList.contiguous?(timespan_list)
    end

    test "returns false if any timespans overlap" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(16, 20),
          Timespan.new(5, 25),
          Timespan.new(25, 30)
        ])

      refute TimespanList.contiguous?(timespan_list)
    end
  end

  describe inspect(&TimespanList.intersection/2) do
    test "returns a timespan list having applied the intersection with the given argument to each timespan" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(-2, 8)
        ])

      operand = Timespan.new(6, 10)

      assert TimespanList.intersection(timespan_list, operand) ==
               TimespanList.new([
                 Timespan.new(6, 10),
                 Timespan.new(6, 10),
                 Timespan.new(6, 8)
               ])
    end

    test "fully excludes timespans that do not overlap the operand" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(17, 25),
          Timespan.new(5, 12),
          Timespan.new(-2, 8)
        ])

      operand = Timespan.new(6, 10)

      assert TimespanList.intersection(timespan_list, operand) ==
               TimespanList.new([
                 Timespan.new(6, 10),
                 Timespan.new(6, 10),
                 Timespan.new(6, 8)
               ])
    end
  end

  describe inspect(&TimespanList.difference/2) do
    test "returns a timespan list having applied the difference with the given argument to each timespan" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(-2, 8)
        ])

      operand = Timespan.new(6, 10)

      assert TimespanList.difference(timespan_list, operand) ==
               TimespanList.new([
                 Timespan.new(0, 6),
                 Timespan.new(10, 16),
                 Timespan.new(5, 6),
                 Timespan.new(10, 12),
                 Timespan.new(-2, 6)
               ])
    end

    test "includes full timespans that do not overlap the operand" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(17, 25),
          Timespan.new(5, 12),
          Timespan.new(-2, 8)
        ])

      operand = Timespan.new(6, 10)

      assert TimespanList.difference(timespan_list, operand) ==
               TimespanList.new([
                 Timespan.new(0, 6),
                 Timespan.new(10, 16),
                 Timespan.new(17, 25),
                 Timespan.new(5, 6),
                 Timespan.new(10, 12),
                 Timespan.new(-2, 6)
               ])
    end
  end

  describe inspect(&TimespanList.split/2) do
    test "splits the timespan list at the given offset" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 3),
          Timespan.new(3, 6),
          Timespan.new(6, 10)
        ])

      assert TimespanList.split(timespan_list, 4) == [
               TimespanList.new([
                 Timespan.new(0, 3),
                 Timespan.new(3, 4)
               ]),
               TimespanList.new([
                 Timespan.new(4, 6),
                 Timespan.new(6, 10)
               ])
             ]
    end

    test "splits the timespan list at each offset" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 3),
          Timespan.new(3, 6),
          Timespan.new(6, 10)
        ])

      assert TimespanList.split(timespan_list, [2, 4, 7]) == [
               TimespanList.new([
                 Timespan.new(0, 2)
               ]),
               TimespanList.new([
                 Timespan.new(2, 3),
                 Timespan.new(3, 4)
               ]),
               TimespanList.new([
                 Timespan.new(4, 6),
                 Timespan.new(6, 7)
               ]),
               TimespanList.new([
                 Timespan.new(7, 10)
               ])
             ]
    end

    test "returns an error if a passed offset is not offset-equivalent" do
      timespan_list = TimespanList.new([])

      assert TimespanList.split(timespan_list, "2") ==
               {:error, :timespan_list_split_non_offset_equivalent, "2"}

      assert TimespanList.split(timespan_list, [2, :three, {7}]) ==
               {:error, :timespan_list_split_non_offset_equivalent, [:three, {7}]}
    end
  end

  describe inspect(&TimespanList.union/1) do
    test "returns a union of all the timespans contained in the list" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 10),
          Timespan.new(-2, 2),
          Timespan.new(5, 12)
        ])

      assert TimespanList.union(timespan_list) ==
               TimespanList.new([
                 Timespan.new(-2, 12)
               ])
    end

    test "does not create a single timespan out of non-overlapping timespans" do
      timespan_list =
        TimespanList.new([
          Timespan.new(-2, 2),
          Timespan.new(4, 8),
          Timespan.new(5, 12)
        ])

      assert TimespanList.union(timespan_list) ==
               TimespanList.new([
                 Timespan.new(-2, 2),
                 Timespan.new(4, 12)
               ])
    end

    test "a timespan list with a single timespan returns itself" do
      timespan_list =
        TimespanList.new([
          Timespan.new(-2, 2)
        ])

      assert TimespanList.union(timespan_list) == timespan_list
    end
  end

  describe inspect(&TimespanList.intersection/1) do
    test "returns the intersection of all timespans in the list" do
      timespan_list =
        TimespanList.new([
          Timespan.new(-2, 10),
          Timespan.new(3, 9),
          Timespan.new(7, 15)
        ])

      assert TimespanList.intersection(timespan_list) ==
               TimespanList.new([
                 Timespan.new(7, 9)
               ])
    end

    test "returns an empty timespan list if any elements do not overlap" do
      timespan_list =
        TimespanList.new([
          Timespan.new(-2, 10),
          Timespan.new(10, 15)
        ])

      assert TimespanList.intersection(timespan_list) == TimespanList.new([])
    end

    test "a timespan list with a single timespan always returns itself" do
      timespan_list =
        TimespanList.new([
          Timespan.new(-2, 2)
        ])

      assert TimespanList.intersection(timespan_list) == timespan_list
    end
  end

  describe inspect(&TimespanList.xor/1) do
    test "an empty list xors to an empty list" do
      assert TimespanList.xor(TimespanList.new()) == TimespanList.new()
    end

    test "a list with a single element returns itself" do
      timespan_list = TimespanList.new([Timespan.new(0, 10)])

      assert TimespanList.xor(timespan_list) == timespan_list
    end

    test "a list with no overlapping timespans returns itself" do
      timespan_list =
        TimespanList.new([
          Timespan.new(-2, 2),
          Timespan.new(10, 20)
        ])

      assert TimespanList.xor(timespan_list) == timespan_list
    end

    test "a longer list returns only the non-overlapping portions of the included timespans" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 10),
          Timespan.new(5, 12)
        ])

      assert TimespanList.xor(timespan_list) ==
               TimespanList.new([
                 Timespan.new(0, 5),
                 Timespan.new(10, 12)
               ])

      timespan_list =
        TimespanList.new([
          Timespan.new(0, 10),
          Timespan.new(5, 12),
          Timespan.new(-2, 2)
        ])

      assert TimespanList.xor(timespan_list) ==
               TimespanList.new([
                 Timespan.new(-2, 0),
                 Timespan.new(2, 5),
                 Timespan.new(10, 12)
               ])

      timespan_list =
        TimespanList.new([
          Timespan.new(0, 10),
          Timespan.new(4, 8),
          Timespan.new(2, 6)
        ])

      assert TimespanList.xor(timespan_list) ==
               TimespanList.new([
                 Timespan.new(0, 2),
                 Timespan.new(8, 10)
               ])
    end

    test "a timespan list where timespans begin or end at the same time only returns one timespan" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 10),
          Timespan.new(0, 5),
          Timespan.new(0, 3)
        ])

      assert TimespanList.xor(timespan_list) == TimespanList.new([Timespan.new(5, 10)])

      timespan_list =
        TimespanList.new([
          Timespan.new(0, 10),
          Timespan.new(5, 10),
          Timespan.new(3, 10)
        ])

      assert TimespanList.xor(timespan_list) == TimespanList.new([Timespan.new(0, 3)])
    end
  end

  describe inspect(&TimespanList.explode/2) do
    test "explodes the list into fully non-overlapping lists if no list limit is given" do
      timespan_list =
        TimespanList.new([
          Timespan.new(-2, 8),
          Timespan.new(-2, 1),
          Timespan.new(0, 16),
          Timespan.new(4, 7),
          Timespan.new(4, 11),
          Timespan.new(5, 12),
          Timespan.new(11, 13),
          Timespan.new(14, 17),
          Timespan.new(15, 20)
        ])

      assert TimespanList.explode(timespan_list) == [
               TimespanList.new([Timespan.new(-2, 8)]),
               TimespanList.new([
                 Timespan.new(-2, 1),
                 Timespan.new(4, 7),
                 Timespan.new(11, 13)
               ]),
               TimespanList.new([
                 Timespan.new(0, 16)
               ]),
               TimespanList.new([
                 Timespan.new(4, 11),
                 Timespan.new(14, 17)
               ]),
               TimespanList.new([
                 Timespan.new(5, 12),
                 Timespan.new(15, 20)
               ])
             ]
    end

    test "explodes the list into the specified number of sets" do
      timespan_list =
        TimespanList.new([
          Timespan.new(-2, 8),
          Timespan.new(-2, 1),
          Timespan.new(0, 16),
          Timespan.new(4, 7),
          Timespan.new(4, 11),
          Timespan.new(5, 12),
          Timespan.new(11, 13),
          Timespan.new(14, 17),
          Timespan.new(15, 20)
        ])

      assert TimespanList.explode(timespan_list, 2) == [
               TimespanList.new([
                 Timespan.new(-2, 8),
                 Timespan.new(4, 7),
                 Timespan.new(4, 11),
                 Timespan.new(11, 13),
                 Timespan.new(14, 17)
               ]),
               TimespanList.new([
                 Timespan.new(-2, 1),
                 Timespan.new(0, 16),
                 Timespan.new(5, 12),
                 Timespan.new(15, 20)
               ])
             ]
    end
  end

  describe inspect(&TimespanList.partition/2) do
    test "partitions timespans into overlapping sections" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 10),
          Timespan.new(5, 15),
          Timespan.new(15, 20),
          Timespan.new(25, 30)
        ])

      assert TimespanList.partition(timespan_list) ==
               [
                 TimespanList.new([Timespan.new(0, 10), Timespan.new(5, 15)]),
                 TimespanList.new([Timespan.new(15, 20)]),
                 TimespanList.new([Timespan.new(25, 30)])
               ]
    end

    test "can include adjoining timespans as well" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 10),
          Timespan.new(5, 15),
          Timespan.new(15, 20),
          Timespan.new(25, 30)
        ])

      assert TimespanList.partition(timespan_list, include_adjoining: true) ==
               [
                 TimespanList.new([
                   Timespan.new(0, 10),
                   Timespan.new(5, 15),
                   Timespan.new(15, 20)
                 ]),
                 TimespanList.new([Timespan.new(25, 30)])
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

    test "can bind the output to a given range" do
      expected = File.read!("test/files/timespan_list_ranged.ly") |> String.trim()

      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(-2, 8),
          Timespan.new(15, 20),
          Timespan.new(24, 30)
        ])

      assert Satie.to_lilypond(timespan_list, range: -10..50) == expected
    end
  end
end
