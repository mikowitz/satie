defmodule Satie.StopHairpinTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.StopHairpin

  doctest StopHairpin

  describe_function &String.Chars.to_string/1 do
    test "returns a string represenation of a hairpin stop" do
      assert StopHairpin.new() |> to_string() == "\\!"
    end
  end

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    test "returns the correct lilypond represenation of a hairpin stop" do
      assert StopHairpin.new() |> Satie.to_lilypond() == "\\!"
    end
  end
end
