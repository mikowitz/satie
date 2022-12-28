defmodule Satie.StopPedalTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StopPedal}

  doctest StopPedal

  describe_function &StopPedal.new/1 do
    test "can take atom or string values for the proper pedal names" do
      assert StopPedal.new() == %StopPedal{pedal: :sustain, components: [after: ["\\sustainOff"]]}

      assert StopPedal.new(:sustain) == %StopPedal{
               pedal: :sustain,
               components: [after: ["\\sustainOff"]]
             }

      assert StopPedal.new(:sostenuto) == %StopPedal{
               pedal: :sostenuto,
               components: [after: ["\\sostenutoOff"]]
             }

      assert StopPedal.new(:corda) == %StopPedal{
               pedal: :corda,
               components: [after: ["\\treCorde"]]
             }

      assert StopPedal.new("sustain") == %StopPedal{
               pedal: :sustain,
               components: [after: ["\\sustainOff"]]
             }

      assert StopPedal.new("sostenuto") == %StopPedal{
               pedal: :sostenuto,
               components: [after: ["\\sostenutoOff"]]
             }

      assert StopPedal.new("corda") == %StopPedal{
               pedal: :corda,
               components: [after: ["\\treCorde"]]
             }
    end

    test "returns an error tuple for invalid input" do
      assert StopPedal.new("whatever") == {:error, :stop_pedal_new, "whatever"}
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a pedal start event formatted for IEx" do
      assert StopPedal.new() |> inspect() == "#Satie.StopPedal<sustain>"
      assert StopPedal.new(:sostenuto) |> inspect() == "#Satie.StopPedal<sostenuto>"
      assert StopPedal.new("corda") |> inspect() == "#Satie.StopPedal<corda>"
    end
  end

  describe "attaching a stop pedal event to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StopPedal.new())
        |> Satie.attach(StopPedal.new(:corda))

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 \\sustainOff
                 \\treCorde
               """
               |> String.trim()
    end
  end
end
