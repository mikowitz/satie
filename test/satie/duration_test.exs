defmodule Satie.DurationTest do
  use ExUnit.Case

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
end
