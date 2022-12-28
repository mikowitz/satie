defmodule Satie.TieTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, Tie}

  doctest Tie

  describe_function &Tie.new/0 do
    test "returns the correct components" do
      assert Tie.new() == %Tie{
               components: [after: ["~"]]
             }
    end
  end

  describe "attaching a tie to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(Tie.new(), direction: :up)

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 ^ ~
               """
               |> String.trim()
    end
  end
end
