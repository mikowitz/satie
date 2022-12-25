defmodule Satie.StopPedalTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.StopPedal

  doctest StopPedal

  describe_function &StopPedal.new/1 do
    test "can take atom or string values for the proper pedal names" do
      assert StopPedal.new() == %StopPedal{pedal: :sustain}
      assert StopPedal.new(:sustain) == %StopPedal{pedal: :sustain}
      assert StopPedal.new(:sostenuto) == %StopPedal{pedal: :sostenuto}
      assert StopPedal.new(:corda) == %StopPedal{pedal: :corda}
      assert StopPedal.new("sustain") == %StopPedal{pedal: :sustain}
      assert StopPedal.new("sostenuto") == %StopPedal{pedal: :sostenuto}
      assert StopPedal.new("corda") == %StopPedal{pedal: :corda}
    end

    test "returns an error tuple for invalid input" do
      assert StopPedal.new("whatever") == {:error, :stop_pedal_new, "whatever"}
    end
  end

  describe_function &String.Chars.to_string/1 do
    test "returns a string representation of a pedal start event" do
      assert StopPedal.new() |> to_string() == "\\sustainOff"
      assert StopPedal.new(:sostenuto) |> to_string() == "\\sostenutoOff"
      assert StopPedal.new("corda") |> to_string() == "\\treCorde"
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a pedal start event formatted for IEx" do
      assert StopPedal.new() |> inspect() == "#Satie.StopPedal<sustain>"
      assert StopPedal.new(:sostenuto) |> inspect() == "#Satie.StopPedal<sostenuto>"
      assert StopPedal.new("corda") |> inspect() == "#Satie.StopPedal<corda>"
    end
  end

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    test "returns a correct lilypond representation of a pedal start event" do
      assert StopPedal.new() |> Satie.to_lilypond() == "\\sustainOff"
      assert StopPedal.new(:sostenuto) |> Satie.to_lilypond() == "\\sostenutoOff"
      assert StopPedal.new("corda") |> Satie.to_lilypond() == "\\treCorde"
    end
  end
end
