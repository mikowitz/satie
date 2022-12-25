defmodule Satie.BarlineTest do
  use ExUnit.Case, async: true

  import DescribeFunction

  alias Satie.Barline

  doctest Barline

  describe_function &Barline.new/1 do
    test "creates a barline with the given symbol input" do
      assert Barline.new("|.") == %Barline{
               symbol: "|."
             }
    end
  end

  describe_function &String.Chars.to_string/1 do
    test "returns reasonable string output for the barline" do
      assert Barline.new("||") |> to_string() == ~s(\\bar "||")
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a barline formatted for IEx" do
      assert Barline.new("|.|") |> inspect() == "#Satie.Barline<|.|>"
    end
  end

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    test "returns the correct lilypond representation of a barline" do
      assert Barline.new("||") |> Satie.to_lilypond() == ~s(\\bar "||")
    end
  end
end
