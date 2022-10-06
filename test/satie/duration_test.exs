defmodule Satie.DurationTest do
  use ExUnit.Case, async: true

  import Satie.RegressionDataStreamer
  alias Satie.Duration

  describe inspect(&Duration.new/2) do
    test "returns a duration from numerator and denominator" do
      assert Duration.new(1, 4) == %Duration{
               numerator: 1,
               denominator: 4
             }

      assert Duration.new(-2, 4) == %Duration{
               numerator: -1,
               denominator: 2
             }

      assert Duration.new(-4, -5) == %Duration{
               numerator: 4,
               denominator: 5
             }

      assert Duration.new(0, -5) == %Duration{
               numerator: 0,
               denominator: 1
             }
    end

    test "returns an error if the denominator is 0" do
      assert Duration.new(1, 0) == {:error, :duration_new, {1, 0}}
    end

    test "returns an error if either argument is not an integer" do
      assert Duration.new(1, 0.5) == {:error, :duration_new, {1, 0.5}}

      assert Duration.new("1", 1) == {:error, :duration_new, {"1", 1}}

      assert Duration.new(1.0, 1) == {:error, :duration_new, {1.0, 1}}
    end

    regression_test(:duration, :new, fn [n_in, d_in, n_out, d_out] ->
      {n_in, ""} = Integer.parse(n_in)
      {d_in, ""} = Integer.parse(d_in)
      {n_out, ""} = Integer.parse(n_out)
      {d_out, ""} = Integer.parse(d_out)

      assert Duration.new(n_in, d_in) == Duration.new(n_out, d_out)
    end)
  end

  describe inspect(&Duration.printable?/1) do
    test "returns true if a duration can be printed on a staff" do
      assert Duration.new(1, 4) |> Duration.printable?()
      assert Duration.new(3, 8) |> Duration.printable?()
      assert Duration.new(7, 32) |> Duration.printable?()
    end

    test "returns false if a duration cannot be printed on a staff" do
      refute Duration.new(0, 4) |> Duration.printable?()
      refute Duration.new(3, 5) |> Duration.printable?()
      refute Duration.new(5, 8) |> Duration.printable?()
      refute Duration.new(5, 1) |> Duration.printable?()
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a lilypond representation of the duration if it is printable" do
      assert Duration.new(1, 4) |> to_string() == "4"
      assert Duration.new(3, 8) |> to_string() == "4."
      assert Duration.new(7, 32) |> to_string() == "8.."
    end

    test "returns a fraction representation of the duration if it is not printable" do
      assert Duration.new(1, 3) |> to_string() == "(1,3)"
      assert Duration.new(-3, 8) |> to_string() == "(-3,8)"
      assert Duration.new(5, 1) |> to_string() == "(5,1)"
      assert Duration.new(5, 8) |> to_string() == "(5,8)"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns the duration formatted for IEx" do
      assert Duration.new(1, 4) |> inspect() == "#Satie.Duration<4>"
      assert Duration.new(3, 4) |> inspect() == "#Satie.Duration<2.>"
      assert Duration.new(-1, 4) |> inspect() == "#Satie.Duration<(-1,4)>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns a lilypond representation of a printable duration" do
      assert Duration.new(1, 4) |> Satie.to_lilypond() == "4"
      assert Duration.new(3, 8) |> Satie.to_lilypond() == "4."
    end

    test "returns an error tuple for a non-printable duration" do
      assert Duration.new(1, 3) |> Satie.to_lilypond() == {:error, :unprintable_duration, {1, 3}}
      assert Duration.new(5, 1) |> Satie.to_lilypond() == {:error, :unprintable_duration, {5, 1}}
      assert Duration.new(5, 8) |> Satie.to_lilypond() == {:error, :unprintable_duration, {5, 8}}

      assert Duration.new(1, -8) |> Satie.to_lilypond() ==
               {:error, :unprintable_duration, {-1, 8}}
    end
  end
end
