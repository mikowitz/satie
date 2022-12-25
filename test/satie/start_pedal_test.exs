defmodule Satie.StartPedalTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.StartPedal

  doctest StartPedal

  describe_function &StartPedal.new/1 do
    test "can take atom or string values for the proper pedal names" do
      assert StartPedal.new() == %StartPedal{pedal: :sustain}
      assert StartPedal.new(:sustain) == %StartPedal{pedal: :sustain}
      assert StartPedal.new(:sostenuto) == %StartPedal{pedal: :sostenuto}
      assert StartPedal.new(:corda) == %StartPedal{pedal: :corda}
      assert StartPedal.new("sustain") == %StartPedal{pedal: :sustain}
      assert StartPedal.new("sostenuto") == %StartPedal{pedal: :sostenuto}
      assert StartPedal.new("corda") == %StartPedal{pedal: :corda}
    end

    test "returns an error tuple for invalid input" do
      assert StartPedal.new("whatever") == {:error, :start_pedal_new, "whatever"}
    end
  end

  describe_function &String.Chars.to_string/1 do
    test "returns a string representation of a pedal start event" do
      assert StartPedal.new() |> to_string() == "\\sustainOn"
      assert StartPedal.new(:sostenuto) |> to_string() == "\\sostenutoOn"
      assert StartPedal.new("corda") |> to_string() == "\\unaCorda"
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a pedal start event formatted for IEx" do
      assert StartPedal.new() |> inspect() == "#Satie.StartPedal<sustain>"
      assert StartPedal.new(:sostenuto) |> inspect() == "#Satie.StartPedal<sostenuto>"
      assert StartPedal.new("corda") |> inspect() == "#Satie.StartPedal<corda>"
    end
  end

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    test "returns a correct lilypond representation of a pedal start event" do
      assert StartPedal.new() |> Satie.to_lilypond() == "\\sustainOn"
      assert StartPedal.new(:sostenuto) |> Satie.to_lilypond() == "\\sostenutoOn"
      assert StartPedal.new("corda") |> Satie.to_lilypond() == "\\unaCorda"
    end
  end
end
