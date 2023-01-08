defmodule Satie.TaleaTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.Talea

  describe_function &Talea.new/1 do
    test "takes a list and returns a streamable cycle" do
      talea = Talea.new([1, 2, 3, 4])

      assert is_function(talea.stream, 2)
    end
  end

  describe_function &Talea.at/2 do
    test "returns the 0-indexed element at the given index" do
      talea = Talea.new([1, 2, 3, 4])

      assert Talea.at(talea, 0) == 1
      assert Talea.at(talea, 5) == 2
      assert Talea.at(talea, 9999) == 4
    end
  end

  describe_function &Talea.drop/2 do
    test "convenience wrapper for `Stream.drop/2`" do
      talea = Talea.new([1, 2, 3, 4])

      assert Talea.drop(talea, 3) |> Talea.at(0) == 4
    end
  end

  describe_function &Talea.take/2 do
    test "convenience wrapper for `Enum.take/2`" do
      talea = Talea.new([1, 2, 3, 4])

      assert Talea.take(talea, 10) == [1, 2, 3, 4, 1, 2, 3, 4, 1, 2]
    end
  end
end
