defmodule Satie.StopBeamTest do
  use ExUnit.Case, async: true

  alias Satie.StopBeam

  doctest StopBeam

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a slur stop" do
      assert StopBeam.new() |> to_string() == "]"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a slur start" do
      assert StopBeam.new() |> Satie.to_lilypond() == "]"
    end
  end
end
