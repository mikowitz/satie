defmodule Satie.MultiplierTest do
  use ExUnit.Case, async: true

  alias Satie.Multiplier

  describe inspect(&Multiplier.new/2) do
    test "takes integral numerator and denominator" do
      assert Multiplier.new(2, 3) == %Multiplier{
               numerator: 2,
               denominator: 3
             }
    end

    test "doesnt' reduce fractions" do
      assert Multiplier.new(4, 6) == %Multiplier{
               numerator: 4,
               denominator: 6
             }
    end

    test "errors if either parameter is not an integer" do
      for invalid <- ["4", :four, [4]] do
        assert Multiplier.new(invalid, 2) == {:error, :multiplier_new, {invalid, 2}}

        assert Multiplier.new(3, invalid) == {:error, :multiplier_new, {3, invalid}}
      end
    end
  end
end
