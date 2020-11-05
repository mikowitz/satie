defmodule Satie.RestTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Rest}
  doctest Rest

  describe ".new" do
    test "/1 accepts a lilypond string" do
      rest = Rest.new("r4..")

      assert %Duration{
               numerator: 7,
               denominator: 16
             } == rest.written_duration
    end

    test "/1 accepts a duration" do
      rest = Rest.new(Duration.new())

      assert %Duration{
               numerator: 1,
               denominator: 4
             } == rest.written_duration
    end

    test "/1 throws an error if it receives an unassignable duration" do
      assert_raise Satie.UnassignableDurationError, fn ->
        Rest.new(Duration.new(1, 5))
      end
    end
  end

  describe "Satie.ToLilypond" do
    test ".to_lilypond/1 returns the correct lilypond representation of the rest" do
      assert Rest.new(Duration.new(3, 8)) |> Satie.to_lilypond() === "r4."
    end
  end
end
