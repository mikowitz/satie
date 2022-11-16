defmodule Satie.TieTest do
  use ExUnit.Case, async: true

  alias Satie.Tie

  doctest Tie

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a tie" do
      assert Tie.new() |> to_string() == "- ~"

      assert Tie.new(:up) |> to_string() == "^ ~"

      assert Tie.new(:down) |> to_string() == "_ ~"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a tie" do
      assert Tie.new() |> Satie.to_lilypond() == "- ~"

      assert Tie.new(:up) |> Satie.to_lilypond() == "^ ~"

      assert Tie.new(:down) |> Satie.to_lilypond() == "_ ~"
    end
  end
end
