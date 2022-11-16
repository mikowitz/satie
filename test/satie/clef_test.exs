defmodule Satie.ClefTest do
  use ExUnit.Case, async: true

  alias Satie.Clef

  describe "new/1" do
    test "creates a clef struct" do
      assert Clef.new("treble") == %Clef{
               name: "treble"
             }
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a clef" do
      assert Clef.new("treble") |> to_string() == "treble"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a clef for IEx" do
      assert Clef.new("treble") |> inspect() == "#Satie.Clef<treble>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a clef" do
      assert Clef.new("treble") |> Satie.to_lilypond() == ~s(\\clef "treble")
    end
  end
end
