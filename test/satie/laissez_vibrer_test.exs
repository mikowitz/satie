defmodule Satie.LaissezVibrerTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Chord, LaissezVibrer}

  doctest LaissezVibrer

  describe_function &LaissezVibrer.new/0 do
    test "returns the correct components" do
      assert LaissezVibrer.new() == %LaissezVibrer{
               components: [
                 after: ["\\laissezVibrer"]
               ]
             }
    end
  end

  describe "attaching a laissez vibrer to a chord" do
    test "returns the correct lilypond" do
      chord =
        Chord.new("< c e g >8")
        |> Satie.attach(LaissezVibrer.new(), direction: :up)

      assert Satie.to_lilypond(chord) ==
               """
               <
                 c
                 e
                 g
               >8
                 ^ \\laissezVibrer
               """
               |> String.trim()
    end
  end
end
