defmodule Satie.OffsetTest do
  use ExUnit.Case, async: true

  alias Satie.Offset

  doctest Offset

  describe "to_float/1" do
    test "converts an offset to a float representation of its place on the timeline" do
      offset = Offset.new(1)

      assert Offset.to_float(offset) == 1.0

      offset2 = Offset.new(18, 16)

      assert Offset.to_float(offset2) == 1.125
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a reasonable string output for an offset" do
      assert Offset.new(1) |> to_string() == "Offset({1, 1})"
    end
  end
end
