defmodule Satie.TimespanTest do
  use ExUnit.Case, async: true

  alias Satie.Timespan

  doctest Timespan

  describe "overlap?/2" do
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
      timespan2 = Timespan.new(12, 23)

      refute Timespan.overlap?(timespan1, timespan2)
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
