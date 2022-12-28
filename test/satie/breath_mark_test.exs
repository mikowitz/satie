defmodule Satie.BreathMarkTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{BreathMark, Rest}

  doctest BreathMark

  describe_function &BreathMark.new/0 do
    test "returns the correct components for the breathmark" do
      assert BreathMark.new() == %BreathMark{
               components: [
                 after: ["\\breathe"]
               ]
             }
    end
  end

  describe "attaching a breathmark to a rest" do
    test "returns the correct lilypond" do
      rest =
        Rest.new("r4")
        |> Satie.attach(BreathMark.new())

      assert Satie.to_lilypond(rest) ==
               """
               r4
                 \\breathe
               """
               |> String.trim()
    end
  end
end
