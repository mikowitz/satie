defmodule Satie.MultiplierTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Multiplier, Offset}

  describe inspect(&Multiplier.new/2) do
    test "takes integral numerator and denominator" do
      assert Multiplier.new(2, 3) == %Multiplier{
               numerator: 2,
               denominator: 3
             }
    end

    test "reduces fractions" do
      assert Multiplier.new(4, 6) == %Multiplier{
               numerator: 2,
               denominator: 3
             }
    end

    test "errors if either parameter is not an integer" do
      for invalid <- ["4", :four, [4]] do
        assert Multiplier.new(invalid, 2) == {:error, :multiplier_new, {invalid, 2}}

        assert Multiplier.new(3, invalid) == {:error, :multiplier_new, {3, invalid}}
      end
    end
  end

  describe "arithmetic" do
    test "against a duration" do
      m = Multiplier.new(1, 5)
      d = Duration.new(1, 8)

      assert is_struct(Multiplier.add(m, d), Multiplier)
      assert is_struct(Multiplier.subtract(m, d), Multiplier)
      assert is_struct(Multiplier.multiply(m, d), Duration)
      assert is_struct(Multiplier.divide(m, d), Multiplier)
    end

    test "against an integer" do
      m = Multiplier.new(1, 5)

      assert is_struct(Multiplier.multiply(m, 2), Multiplier)
      assert is_struct(Multiplier.divide(m, 2), Multiplier)
    end

    test "against another multiplier" do
      m1 = Multiplier.new(1, 5)
      m2 = Multiplier.new(1, 8)

      assert is_struct(Multiplier.add(m1, m2), Multiplier)
      assert is_struct(Multiplier.subtract(m1, m2), Multiplier)
      assert is_struct(Multiplier.multiply(m1, m2), Multiplier)
      assert is_struct(Multiplier.divide(m1, m2), Multiplier)
    end

    test "against an offset" do
      m = Multiplier.new(1, 5)
      o = Offset.new(1, 8)

      assert is_struct(Multiplier.add(m, o), Multiplier)
      assert is_struct(Multiplier.subtract(m, o), Multiplier)
      assert is_struct(Multiplier.multiply(m, o), Multiplier)
      assert is_struct(Multiplier.divide(m, o), Multiplier)
    end
  end
end
