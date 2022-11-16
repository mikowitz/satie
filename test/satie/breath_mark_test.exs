defmodule Satie.BreathMarkTest do
  use ExUnit.Case, async: true

  alias Satie.BreathMark

  doctest BreathMark

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a breath mark" do
      assert BreathMark.new() |> to_string() == "\\breathe"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a breath mark" do
      assert BreathMark.new() |> Satie.to_lilypond() == "\\breathe"
    end
  end
end
