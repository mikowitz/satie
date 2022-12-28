defmodule Satie.StartPhrasingSlurTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StartPhrasingSlur}

  doctest StartPhrasingSlur

  describe_function &StartPhrasingSlur.new/0 do
    test "returns the correct component" do
      assert StartPhrasingSlur.new() == %StartPhrasingSlur{
               components: [after: ["\\("]]
             }
    end
  end

  describe "attaching a phrasing slur to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StartPhrasingSlur.new(), direction: :up)

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 ^ \\(
               """
               |> String.trim()
    end
  end
end
