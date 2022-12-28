defmodule Satie.StartBeamTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StartBeam}

  doctest StartBeam

  describe_function &StartBeam.new/0 do
    test "returns the correct components" do
      assert StartBeam.new() == %StartBeam{
               components: [
                 after: [
                   "["
                 ]
               ]
             }
    end
  end

  describe "attaching a start beam to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StartBeam.new(), direction: :down)

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 _ [
               """
               |> String.trim()
    end
  end
end
