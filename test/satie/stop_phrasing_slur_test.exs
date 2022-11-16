defmodule Satie.StopPhrasingSlurTest do
  use ExUnit.Case, async: true

  alias Satie.StopPhrasingSlur

  doctest StopPhrasingSlur

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a phrasing slur stop" do
      assert StopPhrasingSlur.new() |> to_string() == "\\)"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a phrasing slur start" do
      assert StopPhrasingSlur.new() |> Satie.to_lilypond() == "\\)"
    end
  end
end
