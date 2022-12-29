defmodule Satie.FractionTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Duration, Fraction, Multiplier, Offset}

  describe_function &Fraction.new/1 do
    test "can be created from another fractional type" do
      duration = Duration.new(1, 4)
      fraction = Fraction.new(1, 4)
      multiplier = Multiplier.new(1, 4)
      offset = Offset.new(1, 4)

      assert Fraction.new(duration) == fraction
      assert Fraction.new(fraction) == fraction
      assert Fraction.new(multiplier) == fraction
      assert Fraction.new(offset) == fraction
    end

    test "can be created from a single integer" do
      assert Fraction.new(3) == %Fraction{numerator: 3, denominator: 1}
    end

    test "can be created from a string" do
      assert Fraction.new("4/4") == %Fraction{numerator: 4, denominator: 4}
    end
  end

  describe_function &Fraction.new/2 do
    test "takes integral numerator and denominator" do
      assert Fraction.new(1, 4) == %Fraction{
               numerator: 1,
               denominator: 4
             }
    end

    test "does not reduce the fraction" do
      assert Fraction.new(2, 4) == %Fraction{
               numerator: 2,
               denominator: 4
             }
    end
  end

  describe "arithmetic" do
    test "against a duration" do
      f = Fraction.new(1, 5)
      d = Duration.new(1, 8)

      assert is_struct(Fraction.add(f, d), Fraction)
      assert is_struct(Fraction.subtract(f, d), Fraction)
      assert is_struct(Fraction.multiply(f, d), Fraction)
      assert is_struct(Fraction.divide(f, d), Fraction)
    end

    test "against another fraction" do
      f1 = Fraction.new(1, 5)
      f2 = Fraction.new(1, 8)

      assert is_struct(Fraction.add(f1, f2), Fraction)
      assert is_struct(Fraction.subtract(f1, f2), Fraction)
      assert is_struct(Fraction.multiply(f1, f2), Fraction)
      assert is_struct(Fraction.divide(f1, f2), Fraction)
    end

    test "against an integer" do
      f = Fraction.new(1, 5)

      assert is_struct(Fraction.multiply(f, 2), Fraction)
      assert is_struct(Fraction.divide(f, 2), Fraction)
    end

    test "against a multiplier" do
      f = Fraction.new(1, 5)
      m = Multiplier.new(1, 8)

      assert is_struct(Fraction.add(f, m), Fraction)
      assert is_struct(Fraction.subtract(f, m), Fraction)
      assert is_struct(Fraction.multiply(f, m), Fraction)
      assert is_struct(Fraction.divide(f, m), Fraction)
    end

    test "against an offset" do
      f = Fraction.new(1, 5)
      o = Offset.new(1, 8)

      assert is_struct(Fraction.add(f, o), Fraction)
      assert is_struct(Fraction.subtract(f, o), Fraction)
      assert is_struct(Fraction.multiply(f, o), Fraction)
      assert is_struct(Fraction.divide(f, o), Fraction)
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a fraction formatted for IEx" do
      assert Fraction.new(3, 4) |> inspect() == "#Satie.Fraction<3/4>"
    end
  end
end
