defmodule Satie.DynamicTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Dynamic, Note}

  doctest Dynamic

  describe_function &Dynamic.new/1 do
    test "returns the correct components" do
      assert Dynamic.new("mp") == %Dynamic{
               dynamic: "mp",
               components: [
                 after: [
                   "\\mp"
                 ]
               ]
             }
    end
  end

  describe "attaching a dynamic to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(Dynamic.new("fff"))

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 - \\fff
               """
               |> String.trim()
    end
  end
end
