defmodule Satie.StartSlurTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StartSlur}

  doctest StartSlur

  describe_function &StartSlur.new/0 do
    test "returns the correct component" do
      assert StartSlur.new() == %StartSlur{
               components: [
                 after: ["("]
               ]
             }
    end
  end

  describe "attaching a slur to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StartSlur.new())

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 - (
               """
               |> String.trim()
    end
  end
end
