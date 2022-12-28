defmodule Satie.ClefTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Clef, Note}

  describe_function &Clef.new/1 do
    test "creates a clef struct" do
      assert Clef.new("treble") == %Clef{
               name: "treble",
               components: [before: ["\\clef \"treble\""]]
             }
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a clef for IEx" do
      assert Clef.new("treble") |> inspect() == "#Satie.Clef<treble>"
    end
  end

  describe "attaching a clef to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c4")
        |> Satie.attach(Clef.new("bass"))

      assert Satie.to_lilypond(note) ==
               """
               \\clef "bass"
               c4
               """
               |> String.trim()
    end
  end
end
