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

  describe "comparisons" do
    setup do
      offset1 = Offset.new(-10)
      offset2 = Offset.new(7, 16)
      offset3 = Offset.new(3)
      {:ok, offset1: offset1, offset2: offset2, offset3: offset3}
    end

    test "lt", context do
      assert Offset.lt(context.offset1, context.offset2)
      assert Offset.lt(context.offset1, context.offset3)
      assert Offset.lt(context.offset2, context.offset3)

      refute Offset.lt(context.offset1, context.offset1)
      refute Offset.lt(context.offset2, context.offset1)
      refute Offset.lt(context.offset2, context.offset2)
      refute Offset.lt(context.offset3, context.offset1)
      refute Offset.lt(context.offset3, context.offset2)
      refute Offset.lt(context.offset3, context.offset3)
    end

    test "lte", context do
      assert Offset.lte(context.offset1, context.offset2)
      assert Offset.lte(context.offset1, context.offset3)
      assert Offset.lte(context.offset2, context.offset3)

      assert Offset.lte(context.offset1, context.offset1)
      assert Offset.lte(context.offset2, context.offset2)
      assert Offset.lte(context.offset3, context.offset3)

      refute Offset.lte(context.offset2, context.offset1)
      refute Offset.lte(context.offset3, context.offset1)
      refute Offset.lte(context.offset3, context.offset2)
    end

    test "gt", context do
      assert Offset.gt(context.offset3, context.offset1)
      assert Offset.gt(context.offset3, context.offset2)
      assert Offset.gt(context.offset2, context.offset1)

      refute Offset.gt(context.offset1, context.offset1)
      refute Offset.gt(context.offset1, context.offset2)
      refute Offset.gt(context.offset1, context.offset3)
      refute Offset.gt(context.offset2, context.offset2)
      refute Offset.gt(context.offset2, context.offset3)
      refute Offset.gt(context.offset3, context.offset3)
    end

    test "gte", context do
      assert Offset.gte(context.offset3, context.offset1)
      assert Offset.gte(context.offset3, context.offset2)
      assert Offset.gte(context.offset2, context.offset1)

      assert Offset.gte(context.offset1, context.offset1)
      assert Offset.gte(context.offset2, context.offset2)
      assert Offset.gte(context.offset3, context.offset3)

      refute Offset.gte(context.offset1, context.offset2)
      refute Offset.gte(context.offset1, context.offset3)
      refute Offset.gte(context.offset2, context.offset3)
    end

    test "eq", context do
      assert Offset.eq(context.offset1, context.offset1)
      assert Offset.eq(context.offset2, context.offset2)
      assert Offset.eq(context.offset3, context.offset3)

      refute Offset.eq(context.offset1, context.offset2)
      refute Offset.eq(context.offset1, context.offset3)
      refute Offset.eq(context.offset2, context.offset3)
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a reasonable string output for an offset" do
      assert Offset.new(1) |> to_string() == "Offset({1, 1})"
    end
  end
end
