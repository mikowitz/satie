defmodule Satie.StopSlurTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StopSlur}

  doctest StopSlur

  describe_function &StopSlur.new/0 do
    test "returns the correct components" do
      assert StopSlur.new() == %StopSlur{
               components: [after: [")"]]
             }
    end
  end

  describe "attaching a stop slur event to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StopSlur.new())

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 )
               """
               |> String.trim()
    end
  end
end
