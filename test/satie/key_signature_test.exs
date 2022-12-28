defmodule Satie.KeySignatureTest do
  use ExUnit.Case, async: true

  import DescribeFunction

  alias Satie.{KeySignature, Note, PitchClass}

  doctest KeySignature

  describe_function &KeySignature.new/2 do
    test "returns the correct components" do
      assert KeySignature.new("d") == %KeySignature{
               pitch_class: PitchClass.new("d"),
               mode: :major,
               components: [
                 before: [
                   "\\key d \\major"
                 ]
               ]
             }
    end
  end

  describe "attaching a key signature to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("ef'8")
        |> Satie.attach(KeySignature.new("ef", :lydian))

      assert Satie.to_lilypond(note) ==
               """
               \\key ef \\lydian
               ef'8
               """
               |> String.trim()
    end
  end
end
