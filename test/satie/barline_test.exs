defmodule Satie.BarlineTest do
  use ExUnit.Case, async: true

  import DescribeFunction

  alias Satie.{Articulation, Barline, Note}

  doctest Barline

  describe_function &Barline.new/1 do
    test "creates a barline with the given symbol input" do
      assert Barline.new("|.") == %Barline{
               symbol: "|.",
               components: [
                 after: [
                   "\\bar \"|.\""
                 ]
               ]
             }
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns a barline formatted for IEx" do
      assert Barline.new("|.|") |> inspect() == "#Satie.Barline<\"|.|\">"
    end
  end

  describe "attaching a barline to a note" do
    test "correctly prioritizes the barline at the end of attachments" do
      note =
        Note.new("c'4")
        |> Satie.attach(Barline.new("||"))
        |> Satie.attach(Articulation.new("accent"))

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 - \\accent
                 \\bar "||"
               """
               |> String.trim()
    end
  end
end
