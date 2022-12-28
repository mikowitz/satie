defmodule Satie.StartPedalTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StartPedal}

  doctest StartPedal

  describe_function &StartPedal.new/1 do
    test "can take atom or string values for the proper pedal names" do
      assert StartPedal.new() == %StartPedal{
               pedal: :sustain,
               components: [after: ["\\sustainOn"]]
             }

      assert StartPedal.new(:sustain) == %StartPedal{
               pedal: :sustain,
               components: [after: ["\\sustainOn"]]
             }

      assert StartPedal.new(:sostenuto) == %StartPedal{
               pedal: :sostenuto,
               components: [after: ["\\sostenutoOn"]]
             }

      assert StartPedal.new(:corda) == %StartPedal{
               pedal: :corda,
               components: [after: ["\\unaCorda"]]
             }

      assert StartPedal.new("sustain") == %StartPedal{
               pedal: :sustain,
               components: [after: ["\\sustainOn"]]
             }

      assert StartPedal.new("sostenuto") == %StartPedal{
               pedal: :sostenuto,
               components: [after: ["\\sostenutoOn"]]
             }

      assert StartPedal.new("corda") == %StartPedal{
               pedal: :corda,
               components: [after: ["\\unaCorda"]]
             }
    end

    test "returns an error tuple for invalid input" do
      assert StartPedal.new("whatever") == {:error, :start_pedal_new, "whatever"}
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a pedal start event formatted for IEx" do
      assert StartPedal.new() |> inspect() == "#Satie.StartPedal<sustain>"
      assert StartPedal.new(:sostenuto) |> inspect() == "#Satie.StartPedal<sostenuto>"
      assert StartPedal.new("corda") |> inspect() == "#Satie.StartPedal<corda>"
    end
  end

  describe "attaching pedal start events to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StartPedal.new("corda"))

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 \\unaCorda
               """
               |> String.trim()
    end
  end
end
