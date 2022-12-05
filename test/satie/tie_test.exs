defmodule Satie.TieTest do
  use ExUnit.Case, async: true

  alias Satie.Tie

  doctest Tie

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a tie" do
      assert Tie.new() |> to_string() == "~"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a tie" do
      assert Tie.new() |> Satie.to_lilypond() == "~"
    end
  end
end
