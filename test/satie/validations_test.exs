defmodule Satie.ValidationsTest do
  use ExUnit.Case, async: true

  alias Satie.Validations

  describe inspect(&Validations.validate_position/1) do
    test "returns :neutral, :up, or :down if they are specifically passed" do
      assert Validations.validate_position(:neutral) == :neutral
      assert Validations.validate_position(:up) == :up
      assert Validations.validate_position(:down) == :down
    end

    test "returns :neutral for any other input" do
      assert Validations.validate_position("neutral") == :neutral
      assert Validations.validate_position(:hello) == :neutral
      assert Validations.validate_position([:up, :down]) == :neutral
    end
  end
end
