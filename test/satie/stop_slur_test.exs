defmodule Satie.StopSlurTest do
  use ExUnit.Case, async: true

  alias Satie.StopSlur

  doctest StopSlur

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a slur stop" do
      assert StopSlur.new() |> to_string() == ")"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a slur start" do
      assert StopSlur.new() |> Satie.to_lilypond() == ")"
    end
  end
end
