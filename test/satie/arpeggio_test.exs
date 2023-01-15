defmodule Satie.ArpeggioTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Arpeggio, Chord}

  describe_function &Arpeggio.new/0 do
    test "creates a normal arpeggio with no argument" do
      assert Arpeggio.new() == %Arpeggio{
               style: :normal,
               components: [
                 before: ["\\arpeggioNormal"],
                 after: ["\\arpeggio"]
               ]
             }
    end
  end

  describe_function &Arpeggio.new/1 do
    test "creates an arpeggio from a valid atom" do
      assert Arpeggio.new(:arrow_up) == %Arpeggio{
               style: :arrow_up,
               components: [
                 before: ["\\arpeggioArrowUp"],
                 after: ["\\arpeggio"]
               ]
             }
    end

    test "creates an arpeggio from a valid string" do
      assert Arpeggio.new("bracket") == %Arpeggio{
               style: :bracket,
               components: [
                 before: ["\\arpeggioBracket"],
                 after: ["\\arpeggio"]
               ]
             }
    end

    test "returns an error for an invalid input" do
      assert Arpeggio.new(:what) == {:error, :arpeggio_new, :what}
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns an arpeggio formatted for IEx" do
      assert Arpeggio.new() |> inspect == "#Satie.Arpeggio<>"
      assert Arpeggio.new(:arrow_down) |> inspect == "#Satie.Arpeggio<arrow_down>"
    end
  end

  describe "attaching an arpeggio to a chord" do
    test "returns the correct lilypond" do
      chord =
        Chord.new("< c e g >8")
        |> Satie.attach(Arpeggio.new(:parenthesis))

      assert Satie.to_lilypond(chord) ==
               """
               \\arpeggioParenthesis
               <
                 c
                 e
                 g
               >8
                 \\arpeggio
               """
               |> String.trim()
    end
  end
end
