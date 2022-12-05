defmodule Satie.ArticulationTest do
  use ExUnit.Case, async: true

  alias Satie.Articulation

  doctest Articulation

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of an articulation" do
      assert Articulation.new("marcato") |> to_string() == "\\marcato"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of an articulation" do
      assert Articulation.new("staccato") |> Satie.to_lilypond() == "\\staccato"
    end
  end
end
