defmodule Satie.RestTest do
  use ExUnit.Case

  alias Satie.{Duration, Rest}
  doctest Rest

  describe ".new" do
    test "/1 accepts a duration" do
      assert Rest.new(Duration.new) == %Rest{
        written_duration: %Duration{
          numerator: 1,
          denominator: 4
        }
      }
    end

    test "/1 throws an error if it receives an unassignable duration" do
      assert_raise Satie.UnassignableDurationError, fn ->
        Rest.new(Duration.new(1, 5))
      end
    end
  end
end
