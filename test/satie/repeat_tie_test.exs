defmodule Satie.RepeatTieTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, RepeatTie}

  doctest RepeatTie

  describe_function &RepeatTie.new/0 do
    test "returns the correct component" do
      assert RepeatTie.new() == %RepeatTie{
               components: [
                 after: ["\\repeatTie"]
               ]
             }
    end
  end

  describe "attaching a repeat tie to a note" do
    note =
      Note.new("c'4")
      |> Satie.attach(RepeatTie.new())

    assert Satie.to_lilypond(note) ==
             """
             c'4
               - \\repeatTie
             """
             |> String.trim()
  end
end
