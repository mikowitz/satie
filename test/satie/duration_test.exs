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

    test "can print breves, longas, maximas" do
      assert Duration.new(2, 1) |> Duration.printable?()
      assert Duration.new(3, 1) |> Duration.printable?()
      assert Duration.new(4, 1) |> Duration.printable?()
      assert Duration.new(6, 1) |> Duration.printable?()
      assert Duration.new(7, 1) |> Duration.printable?()
      assert Duration.new(8, 1) |> Duration.printable?()
      assert Duration.new(12, 1) |> Duration.printable?()
      assert Duration.new(14, 1) |> Duration.printable?()
      assert Duration.new(15, 1) |> Duration.printable?()
    end

    test "returns false if a duration cannot be printed on a staff" do
      refute Duration.new(0, 4) |> Duration.printable?()
      refute Duration.new(3, 5) |> Duration.printable?()
      refute Duration.new(5, 8) |> Duration.printable?()
      refute Duration.new(5, 1) |> Duration.printable?()
    end

    regression_test(:duration, :printable, fn [n, d, printable] ->
      {n, ""} = Integer.parse(n)
      {d, ""} = Integer.parse(d)
      duration = Duration.new(n, d)

      case printable do
        "True" -> assert Duration.printable?(duration)
        "False" -> refute Duration.printable?(duration)
      end
    end)
  end

  describe inspect(&Duration.add/2) do
    test "returns the sum of two durations" do
      quarter = Duration.new(1, 4)
      third = Duration.new(1, 3)
      half = Duration.new(1, 2)
      neg_quarter = Duration.new(-1, 4)

      assert Duration.add(quarter, third) == Duration.new(7, 12)
      assert Duration.add(quarter, half) == Duration.new(3, 4)
      assert Duration.add(quarter, neg_quarter) == Duration.new(0, 1)
      assert Duration.add(third, half) == Duration.new(5, 6)
      assert Duration.add(third, neg_quarter) == Duration.new(1, 12)
      assert Duration.add(half, neg_quarter) == Duration.new(1, 4)
    end

    regression_test(:duration, :add, fn [n1, d1, n2, d2, n3, d3] ->
      {n1, ""} = Integer.parse(n1)
      {d1, ""} = Integer.parse(d1)
      {n2, ""} = Integer.parse(n2)
      {d2, ""} = Integer.parse(d2)
      {n3, ""} = Integer.parse(n3)
      {d3, ""} = Integer.parse(d3)
      duration = Duration.new(n1, d1)
      duration2 = Duration.new(n2, d2)
      sum = Duration.new(n3, d3)

      assert Duration.add(duration, duration2) == sum
    end)
  end

  describe inspect(&Duration.subtract/2) do
    test "returns the difference of two durations" do
      quarter = Duration.new(1, 4)
      third = Duration.new(1, 3)
      half = Duration.new(1, 2)
      neg_quarter = Duration.new(-1, 4)

      assert Duration.subtract(quarter, third) == Duration.new(-1, 12)
      assert Duration.subtract(quarter, half) == Duration.new(-1, 4)
      assert Duration.subtract(quarter, neg_quarter) == Duration.new(1, 2)
      assert Duration.subtract(third, half) == Duration.new(-1, 6)
      assert Duration.subtract(third, neg_quarter) == Duration.new(7, 12)
      assert Duration.subtract(half, neg_quarter) == Duration.new(3, 4)
    end

    regression_test(:duration, :subtract, fn [n1, d1, n2, d2, n3, d3] ->
      {n1, ""} = Integer.parse(n1)
      {d1, ""} = Integer.parse(d1)
      {n2, ""} = Integer.parse(n2)
      {d2, ""} = Integer.parse(d2)
      {n3, ""} = Integer.parse(n3)
      {d3, ""} = Integer.parse(d3)
      duration = Duration.new(n1, d1)
      duration2 = Duration.new(n2, d2)
      diff = Duration.new(n3, d3)

      assert Duration.subtract(duration, duration2) == diff
    end)
  end

  describe inspect(&Duration.multiply/2) do
    test "returns the product of two durations" do
      quarter = Duration.new(1, 4)
      third = Duration.new(1, 3)
      half = Duration.new(1, 2)
      neg_quarter = Duration.new(-1, 4)

      assert Duration.multiply(quarter, third) == Duration.new(1, 12)
      assert Duration.multiply(quarter, half) == Duration.new(1, 8)
      assert Duration.multiply(quarter, neg_quarter) == Duration.new(-1, 16)
      assert Duration.multiply(third, half) == Duration.new(1, 6)
      assert Duration.multiply(third, neg_quarter) == Duration.new(-1, 12)
      assert Duration.multiply(half, neg_quarter) == Duration.new(-1, 8)
    end

    test "returns the product of a duration and an integer" do
      assert Duration.new(1, 4) |> Duration.multiply(2) == Duration.new(1, 2)
      assert Duration.new(1, 4) |> Duration.multiply(3) == Duration.new(3, 4)
    end

    regression_test(:duration, :multiply, fn [n1, d1, n2, d2, n3, d3] ->
      {n1, ""} = Integer.parse(n1)
      {d1, ""} = Integer.parse(d1)
      {n2, ""} = Integer.parse(n2)
      {d2, ""} = Integer.parse(d2)
      {n3, ""} = Integer.parse(n3)
      {d3, ""} = Integer.parse(d3)
      duration = Duration.new(n1, d1)
      duration2 = Duration.new(n2, d2)
      product = Duration.new(n3, d3)

      assert Duration.multiply(duration, duration2) == product
    end)

    regression_test(:duration, :multiply_by_int, fn [n1, d1, i, n2, d2] ->
      {n1, ""} = Integer.parse(n1)
      {d1, ""} = Integer.parse(d1)
      {i, ""} = Integer.parse(i)
      {n2, ""} = Integer.parse(n2)
      {d2, ""} = Integer.parse(d2)
      duration = Duration.new(n1, d1)
      product = Duration.new(n2, d2)

      assert Duration.multiply(duration, i) == product
    end)
  end

  describe inspect(&Duration.divide/2) do
    test "returns the product of two durations" do
      quarter = Duration.new(1, 4)
      third = Duration.new(1, 3)
      half = Duration.new(1, 2)
      neg_quarter = Duration.new(-1, 4)

      assert Duration.divide(quarter, third) == Duration.new(3, 4)
      assert Duration.divide(quarter, half) == Duration.new(1, 2)
      assert Duration.divide(quarter, neg_quarter) == Duration.new(-1, 1)
      assert Duration.divide(third, half) == Duration.new(2, 3)
      assert Duration.divide(third, neg_quarter) == Duration.new(-4, 3)
      assert Duration.divide(half, neg_quarter) == Duration.new(-2, 1)
    end

    test "returns the product of a duration and an integer" do
      assert Duration.new(1, 4) |> Duration.divide(2) == Duration.new(1, 8)
      assert Duration.new(1, 4) |> Duration.divide(3) == Duration.new(1, 12)
    end

    regression_test(:duration, :divide, fn [n1, d1, n2, d2, n3, d3] ->
      {n1, ""} = Integer.parse(n1)
      {d1, ""} = Integer.parse(d1)
      {n2, ""} = Integer.parse(n2)
      {d2, ""} = Integer.parse(d2)
      {n3, ""} = Integer.parse(n3)
      {d3, ""} = Integer.parse(d3)
      duration = Duration.new(n1, d1)
      duration2 = Duration.new(n2, d2)
      quotient = Duration.new(n3, d3)

      assert Duration.divide(duration, duration2) == quotient
    end)

    regression_test(:duration, :multiply_by_int, fn [n1, d1, i, n2, d2] ->
      {n1, ""} = Integer.parse(n1)
      {d1, ""} = Integer.parse(d1)
      {i, ""} = Integer.parse(i)
      {n2, ""} = Integer.parse(n2)
      {d2, ""} = Integer.parse(d2)
      duration = Duration.new(n1, d1)
      quotient = Duration.new(n2, d2)

      assert Duration.multiply(duration, i) == quotient
    end)
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a lilypond representation of the duration if it is printable" do
      assert Duration.new(1, 4) |> to_string() == "4"
      assert Duration.new(3, 8) |> to_string() == "4."
      assert Duration.new(7, 32) |> to_string() == "8.."
    end

    test "special cases for printable breves, longas, maximas" do
      assert Duration.new(2, 1) |> to_string() == "breve"
      assert Duration.new(3, 1) |> to_string() == "breve."

      assert Duration.new(4, 1) |> to_string() == "longa"
      assert Duration.new(7, 1) |> to_string() == "longa.."

      assert Duration.new(8, 1) |> to_string() == "maxima"
      assert Duration.new(15, 1) |> to_string() == "maxima..."
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

      assert Duration.new(2, 1) |> Satie.to_lilypond() == "\\breve"
      assert Duration.new(6, 1) |> Satie.to_lilypond() == "\\longa."
      assert Duration.new(15, 1) |> Satie.to_lilypond() == "\\maxima..."
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
