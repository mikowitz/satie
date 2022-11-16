defmodule Satie.FermataTest do
  use ExUnit.Case, async: true

  alias Satie.Fermata

  doctest Fermata

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a fermata" do
      assert Fermata.new() |> to_string() == "- \\fermata"

      assert Fermata.new(:verylong, :up) |> to_string() == "^ \\verylongfermata"

      assert Fermata.new(:veryshort, :down) |> to_string() == "_ \\veryshortfermata"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a fermata" do
      assert Fermata.new() |> Satie.to_lilypond() == "- \\fermata"

      assert Fermata.new(:verylong, :up) |> Satie.to_lilypond() == "^ \\verylongfermata"

      assert Fermata.new(:veryshort, :down) |> Satie.to_lilypond() == "_ \\veryshortfermata"
    end
  end
end
