defmodule Satie.StartBeamTest do
  use ExUnit.Case, async: true

  alias Satie.StartBeam

  doctest StartBeam

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a beam start" do
      assert StartBeam.new() |> to_string() == "["
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a beam start" do
      assert StartBeam.new() |> Satie.to_lilypond() == "["
    end
  end
end
