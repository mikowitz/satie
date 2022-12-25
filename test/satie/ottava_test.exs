defmodule Satie.OttavaTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.Ottava

  describe_function &Ottava.new/1 do
    test "returns an ottava setting with an integer argument" do
      assert Ottava.new(1) == %Ottava{degree: 1}
    end

    test "returns an error tuple with any non-integer argument" do
      for degree <- ["1", [1], 1.0] do
        assert Ottava.new(degree) == {:error, :ottava_new, degree}
      end
    end
  end

  describe_function &String.Chars.to_string/1 do
    test "returns a string representation of the ottava" do
      assert Ottava.new(-1) |> to_string() == "\\ottava #-1"
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns the ottava setting formatted for IEx" do
      assert Ottava.new(2) |> inspect() == "#Satie.Ottava<2>"
    end
  end

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    test "returns the correct lilypond represenation of the ottava setting" do
      assert Ottava.new(0) |> Satie.to_lilypond() == "\\ottava #0"
    end
  end
end
