defmodule Satie.StopBeamTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StopBeam}

  doctest StopBeam

  describe_function &StopBeam.new/0 do
    test "returns the correct component" do
      assert StopBeam.new() == %StopBeam{
               components: [after: ["]"]]
             }
    end
  end

  describe "attaching a stop beam event to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'8")
        |> Satie.attach(StopBeam.new())

      assert Satie.to_lilypond(note) ==
               """
               c'8
                 ]
               """
               |> String.trim()
    end
  end
end
