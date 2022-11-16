defmodule Satie.KeySignatureTest do
  use ExUnit.Case, async: true

  alias Satie.KeySignature

  doctest KeySignature

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a key signature" do
      assert KeySignature.new("c") |> to_string() == "c major"

      assert KeySignature.new("ef", :minor) |> to_string() == "ef minor"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a key signature" do
      assert KeySignature.new("c") |> Satie.to_lilypond() == "\\key c \\major"

      assert KeySignature.new("ef", :minor) |> Satie.to_lilypond() == "\\key ef \\minor"
    end
  end
end
