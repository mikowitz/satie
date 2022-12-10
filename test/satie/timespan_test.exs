defmodule Satie.TimespanTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Timespan, TimespanList}

  doctest Timespan

  describe inspect(&Timespan.overlap?/2) do
    test "returns true if the two timespans overlap" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(2, 3)

      assert Timespan.overlap?(timespan1, timespan2)
    end

    test "returns false if the two timespans do not overlap" do
      timespan1 = Timespan.new(0, 1)
      timespan2 = Timespan.new(2, 3)

      refute Timespan.overlap?(timespan1, timespan2)
    end

    test "a start_offset does not overlap a stop_offset at the same point" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(10, 23)

      refute Timespan.overlap?(timespan1, timespan2)
    end
  end

  describe inspect(&Timespan.adjoin?/2) do
    test "returns true if one timespan starts where the other stops" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(10, 13)

      assert Timespan.adjoin?(timespan1, timespan2)
    end

    test "returns false if the timespans do not touch" do
      timespan1 = Timespan.new(0, 5)
      timespan2 = Timespan.new(8, 13)

      refute Timespan.adjoin?(timespan1, timespan2)
    end

    test "returns false if the timespans overlap" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(8, 13)

      refute Timespan.adjoin?(timespan1, timespan2)
    end
  end

  describe inspect(&Timespan.union/2) do
    test "returns a single timespan for overlapping timespans" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(8, 12)

      assert Timespan.union(timespan1, timespan2) ==
               TimespanList.new([
                 Timespan.new(0, 12)
               ])
    end

    test "returns a single timespan if the timespans adjoin" do
      timespan1 = Timespan.new(0, 8)
      timespan2 = Timespan.new(8, 12)

      assert Timespan.union(timespan1, timespan2) ==
               TimespanList.new([
                 Timespan.new(0, 12)
               ])
    end

    test "returns both timespans for non-overlapping timespans" do
      timespan1 = Timespan.new(0, 5)
      timespan2 = Timespan.new(8, 12)

      assert Timespan.union(timespan1, timespan2) ==
               TimespanList.new([
                 Timespan.new(0, 5),
                 Timespan.new(8, 12)
               ])
    end
  end

  describe inspect(&Timespan.intersection/2) do
    test "returns a single timespan for overlapping timespans" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(8, 12)

      assert Timespan.intersection(timespan1, timespan2) ==
               TimespanList.new([
                 Timespan.new(8, 10)
               ])
    end

    test "returns an empty timespan list for non-overlapping timespans" do
      timespan1 = Timespan.new(0, 5)
      timespan2 = Timespan.new(8, 12)

      assert Timespan.intersection(timespan1, timespan2) == TimespanList.new([])
    end

    test "adjoining does not count as overlapping" do
      timespan1 = Timespan.new(0, 5)
      timespan2 = Timespan.new(5, 10)

      assert Timespan.intersection(timespan1, timespan2) == TimespanList.new([])
    end
  end

  describe inspect(&Timespan.duration/1) do
    test "returns the lengh of the timespan as a Duration struct" do
      timespan = Timespan.new(0, 7)
      assert Timespan.duration(timespan) == Duration.new(7, 1)
    end
  end

  describe inspect(&Timespan.difference/1) do
    test "returns the first timespan if the timespans do not overlap" do
      timespan1 = Timespan.new(0, 5)
      timespan2 = Timespan.new(6, 8)

      assert Timespan.difference(timespan1, timespan2) == TimespanList.new([timespan1])
      assert Timespan.difference(timespan2, timespan1) == TimespanList.new([timespan2])
    end

    test "returns an empty timespan list if the timespans are identical" do
      timespan = Timespan.new(0, 5)

      assert Timespan.difference(timespan, timespan) == TimespanList.new([])
    end

    test "returns two disjunct timespans if the second timespan is wholly contained by the first" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(6, 8)

      assert Timespan.difference(timespan1, timespan2) ==
               TimespanList.new([
                 Timespan.new(0, 6),
                 Timespan.new(8, 10)
               ])

      assert Timespan.difference(timespan2, timespan1) == TimespanList.new([])
    end

    test "returns a single timespan if the timespans overlap" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(6, 12)

      assert Timespan.difference(timespan1, timespan2) == TimespanList.new([Timespan.new(0, 6)])
      assert Timespan.difference(timespan2, timespan1) == TimespanList.new([Timespan.new(10, 12)])
    end
  end

  describe inspect(&Timespan.xor/1) do
    test "returns both timespans if they do not overlap" do
      timespan1 = Timespan.new(0, 5)
      timespan2 = Timespan.new(6, 12)

      assert Timespan.xor(timespan1, timespan2) == TimespanList.new([timespan1, timespan2])
    end

    test "returns the non-overlapping portions of overlapping timespans" do
      timespan1 = Timespan.new(0, 5)
      timespan2 = Timespan.new(3, 12)

      assert Timespan.xor(timespan1, timespan2) ==
               TimespanList.new([
                 Timespan.new(0, 3),
                 Timespan.new(5, 12)
               ])
    end

    test "returns the outer boundaries of a containing timespan" do
      timespan1 = Timespan.new(0, 10)
      timespan2 = Timespan.new(3, 8)

      assert Timespan.xor(timespan1, timespan2) ==
               TimespanList.new([
                 Timespan.new(0, 3),
                 Timespan.new(8, 10)
               ])
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a reasonable string output for a timespan" do
      assert Timespan.new(0, 10) |> to_string() == "Timespan({0, 1}, {10, 1})"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "scales from 1-50" do
      timespan = Timespan.new(0, 10)

      assert Satie.to_lilypond(timespan) ==
               """
               \\markup \\column {
                 \\overlay {
                   \\translate #'(1.0 . 1)
                   \\fontsize #-2 \\center-align \\fraction 0 1
                   \\translate #'(106.0 . 1)
                   \\fontsize #-2 \\center-align \\fraction 10 1
                 }
                 \\postscript #"
                 0.2 setlinewidth

                 1.0 0.5 moveto
                 1.0 1.5 lineto
                 stroke
                 106.0 0.5 moveto
                 106.0 1.5 lineto
                 stroke
                 1.0 1.0 moveto
                 106.0 1.0 lineto
                 stroke
                 "
               }
               """
               |> String.trim()
    end
  end
end
