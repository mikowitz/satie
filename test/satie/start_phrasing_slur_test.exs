defmodule Satie.StartPhrasingSlurTest do
  use ExUnit.Case, async: true

  alias Satie.StartPhrasingSlur

  doctest StartPhrasingSlur

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a phrasing slur start" do
      assert StartPhrasingSlur.new() |> to_string() == "\\("
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a phrasing slur start" do
      assert StartPhrasingSlur.new() |> Satie.to_lilypond() == "\\("
    end
  end
end
