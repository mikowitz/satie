defmodule Satie.RepeatTieTest do
  use ExUnit.Case, async: true

  alias Satie.RepeatTie

  doctest RepeatTie

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a repeat tie" do
      assert RepeatTie.new() |> to_string() == "- \\repeatTie"

      assert RepeatTie.new(:down) |> to_string() == "_ \\repeatTie"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a tie" do
      assert RepeatTie.new() |> Satie.to_lilypond() == "- \\repeatTie"

      assert RepeatTie.new(:up) |> Satie.to_lilypond() == "^ \\repeatTie"
    end
  end
end
