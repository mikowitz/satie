defmodule Satie.OttavaTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, Ottava}

  describe_function &Ottava.new/1 do
    test "returns an ottava setting with an integer argument" do
      assert Ottava.new(1) == %Ottava{
               degree: 1,
               components: [
                 before: ["\\ottava #1"]
               ]
             }
    end

    test "returns an error tuple with any non-integer argument" do
      for degree <- ["1", [1], 1.0] do
        assert Ottava.new(degree) == {:error, :ottava_new, degree}
      end
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns the ottava setting formatted for IEx" do
      assert Ottava.new(2) |> inspect() == "#Satie.Ottava<2>"
    end
  end

  describe "attaching ottavas to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(Ottava.new(0), position: :after)
        |> Satie.attach(Ottava.new(1))

      assert Satie.to_lilypond(note) ==
               """
               \\ottava #1
               c'4
                 \\ottava #0
               """
               |> String.trim()
    end
  end
end
