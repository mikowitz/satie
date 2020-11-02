defmodule Satie.DurationTest do
  use ExUnit.Case, async: true

  alias Satie.Duration
  doctest Duration

  describe ".new" do
    test "/0 creates a quarter note duration" do
      assert Duration.new() == %Duration{
               numerator: 1,
               denominator: 4
             }
    end

    test "/1 creates a duration of n quarter notes" do
      assert Duration.new(3) == %Duration{
               numerator: 3,
               denominator: 4
             }
    end

    test "/2 allows creation of an unassignable duration" do
      assert Duration.new(1, 5) == %Duration{
               numerator: 1,
               denominator: 5
             }
    end

    test "/2 reduces a duration to its simplest fraction" do
      assert Duration.new(3, 12) == %Duration{
               numerator: 1,
               denominator: 4
             }
    end
  end

  describe ".to_lilypond" do
    test "/1 returns the correct lilypond representation of the duration" do
      assert Duration.new() |> Satie.to_lilypond() === "4"

      assert Duration.new(1, 8) |> Satie.to_lilypond() === "8"

      assert Duration.new(3, 4) |> Satie.to_lilypond() === "2."

      assert Duration.new(7, 16) |> Satie.to_lilypond() === "4.."
    end

    test "/1 raises an error for an unassignable duration" do
      assert_raise Satie.UnassignableDurationError, fn ->
        Duration.new(5, 8) |> Satie.to_lilypond()
      end

      assert_raise Satie.UnassignableDurationError, fn ->
        Duration.new(5, 1) |> Satie.to_lilypond()
      end

      assert_raise Satie.UnassignableDurationError, fn ->
        Duration.new(1, 5) |> Satie.to_lilypond()
      end
    end
  end
end
