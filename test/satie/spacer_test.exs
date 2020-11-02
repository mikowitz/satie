defmodule Satie.SpacerTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Spacer}
  doctest Spacer

  describe ".new" do
    test "/1 accepts a duration" do
      spacer = Spacer.new(Duration.new(3, 16))

      assert %Duration{
               numerator: 3,
               denominator: 16
             } == spacer.written_duration
    end

    test "/1 throws an error if it receives an unassignable duration" do
      assert_raise Satie.UnassignableDurationError, fn ->
        Spacer.new(Duration.new(1, 5))
      end
    end
  end

  describe "Satie.ToLilypond" do
    test ".to_lilypond/1 returns the correct lilypond representation of the rest" do
      assert Spacer.new(Duration.new(7, 8)) |> Satie.to_lilypond() === "s2.."
    end
  end
end
