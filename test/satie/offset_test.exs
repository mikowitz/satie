defmodule Satie.OffsetTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Multiplier, Offset}

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

  describe "arithmetic" do
    test "against a duration" do
      o = Offset.new(1, 3)
      d = Duration.new(1, 8)

      assert is_struct(Offset.add(o, d), Offset)
      assert is_struct(Offset.subtract(o, d), Offset)
      assert is_struct(Offset.multiply(o, d), Offset)
      assert is_struct(Offset.divide(o, d), Offset)
    end

    test "against an integer" do
      o = Offset.new(1, 3)

      assert is_struct(Offset.multiply(o, 2), Offset)
      assert is_struct(Offset.divide(o, 2), Offset)
    end

    test "against a multiplier" do
      o = Offset.new(1, 3)
      m = Multiplier.new(1, 8)

      assert is_struct(Offset.add(o, m), Offset)
      assert is_struct(Offset.subtract(o, m), Offset)
      assert is_struct(Offset.multiply(o, m), Offset)
      assert is_struct(Offset.divide(o, m), Offset)
    end

    test "against another offset" do
      o1 = Offset.new(1, 3)
      o2 = Offset.new(1, 8)

      assert is_struct(Offset.add(o1, o2), Offset)
      assert is_struct(Offset.subtract(o1, o2), Duration)
      assert is_struct(Offset.multiply(o1, o2), Offset)
      assert is_struct(Offset.divide(o1, o2), Multiplier)
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a reasonable string output for an offset" do
      assert Offset.new(1) |> to_string() == "Offset({1, 1})"
    end
  end
end
