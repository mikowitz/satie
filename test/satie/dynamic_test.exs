defmodule Satie.DynamicTest do
  use ExUnit.Case, async: true

  alias Satie.Dynamic

  doctest Dynamic

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of dynamic" do
      assert Dynamic.new("mp") |> to_string() == "\\mp"

      assert Dynamic.new("f") |> to_string() == "\\f"

      assert Dynamic.new("sfz") |> to_string() == "\\sfz"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a dynamic" do
      assert Dynamic.new("mp") |> Satie.to_lilypond() == "\\mp"

      assert Dynamic.new("f") |> Satie.to_lilypond() == "\\f"

      assert Dynamic.new("sfz") |> Satie.to_lilypond() == "\\sfz"
    end
  end
end
