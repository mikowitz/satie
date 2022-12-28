defmodule Satie.StopPhrasingSlurTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StopPhrasingSlur}

  doctest StopPhrasingSlur

  describe_function &StopPhrasingSlur.new/0 do
    test "returns the correct components" do
      assert StopPhrasingSlur.new() == %StopPhrasingSlur{
               components: [
                 after: [
                   "\\)"
                 ]
               ]
             }
    end
  end

  describe "attaching a stop phrasing slur event to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StopPhrasingSlur.new())

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 \\)
               """
               |> String.trim()
    end
  end
end
