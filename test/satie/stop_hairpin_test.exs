defmodule Satie.StopHairpinTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StopHairpin}

  doctest StopHairpin

  describe_function &StopHairpin.new/0 do
    test "returns the correct component" do
      assert StopHairpin.new() == %StopHairpin{
               components: [
                 after: ["\\!"]
               ]
             }
    end
  end

  describe "attaching a stop hairpin event to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StopHairpin.new())

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 \\!
               """
               |> String.trim()
    end
  end
end
