defmodule Satie.Generators.Rhythm.FillTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.Fraction
  alias Satie.Generators.Rhythm.Fill

  doctest Fill

  describe_function &Fill.new/1 do
    test "stores the input fraction tuples as structs" do
      fill = Fill.new([{3, 4}, {2, 4}, 2, {5, 8}])

      assert fill == %Fill{
               fractions: [
                 Fraction.new(3, 4),
                 Fraction.new(2, 4),
                 Fraction.new(2, 1),
                 Fraction.new(5, 8)
               ],
               tie_across_boundaries: false,
               mask: [1]
             }
    end

    test "returns an error if any inputs can't be parsed as a fraction" do
      fill = Fill.new([{3, 4}, "ok", "{3, 4}"])

      assert fill == {:error, :fill_rhythm_generator_new, ["ok", "{3, 4}"]}
    end
  end

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    test "returns the correct lilypond output" do
      fill = Fill.new([{2, 4}, {5, 8}])

      assert Satie.to_lilypond(fill) ==
               """
               \\context RhythmicStaff = "Fill Staff" {
                 {
                   \\time 2/4
                   c2
                   |
                 }
                 {
                   \\time 5/8
                   c2
                     - ~
                   c8
                   |
                 }
               }
               """
               |> String.trim()
    end

    test "can tie across boundaries" do
      fill = Fill.new([{2, 4}, {5, 8}], tie_across_boundaries: true)

      assert Satie.to_lilypond(fill) ==
               """
               \\context RhythmicStaff = "Fill Staff" {
                 {
                   \\time 2/4
                   c2
                     - ~
                   |
                 }
                 {
                   \\time 5/8
                   c2
                     - ~
                   c8
                   |
                 }
               }
               """
               |> String.trim()
    end

    test "can mask a repeating pattern with notes and rests" do
      fill = Fill.new([{2, 4}, {5, 8}, {3, 16}, {1, 4}], mask: [1, 0])

      assert Satie.to_lilypond(fill) ==
               """
               \\context RhythmicStaff = "Fill Staff" {
                 {
                   \\time 2/4
                   c2
                   |
                 }
                 {
                   \\time 5/8
                   r2
                   r8
                   |
                 }
                 {
                   \\time 3/16
                   c8.
                   |
                 }
                 {
                   \\time 1/4
                   r4
                   |
                 }
               }
               """
               |> String.trim()
    end

    test "tie_across_boundaries respects rest masks" do
      fill =
        Fill.new([{2, 4}, {5, 8}, {3, 16}, {1, 4}], mask: [1, 1, 0], tie_across_boundaries: true)

      assert Satie.to_lilypond(fill) ==
               """
               \\context RhythmicStaff = "Fill Staff" {
                 {
                   \\time 2/4
                   c2
                     - ~
                   |
                 }
                 {
                   \\time 5/8
                   c2
                     - ~
                   c8
                   |
                 }
                 {
                   \\time 3/16
                   r8.
                   |
                 }
                 {
                   \\time 1/4
                   c4
                   |
                 }
               }
               """
               |> String.trim()
    end
  end
end
