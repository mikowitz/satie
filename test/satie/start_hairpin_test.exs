defmodule Satie.StartHairpinTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Note, StartHairpin}

  doctest StartHairpin

  describe_function &StartHairpin.new/2 do
    test "can take a lilypond string or a descriptive atom" do
      for token <- [:<, :crescendo, :cresc] do
        assert StartHairpin.new(token) == %StartHairpin{
                 direction: :crescendo,
                 output: :symbol,
                 components: [after: ["\\<"]]
               }

        assert StartHairpin.new(to_string(token), output: :text) == %StartHairpin{
                 direction: :crescendo,
                 output: :text,
                 components: [after: ["\\cresc"]]
               }
      end

      for token <- [:>, :decrescendo, :decresc] do
        assert StartHairpin.new(token, output: :text) == %StartHairpin{
                 direction: :decrescendo,
                 output: :text,
                 components: [after: ["\\decresc"]]
               }

        assert StartHairpin.new(to_string(token), output: :symbol) == %StartHairpin{
                 direction: :decrescendo,
                 output: :symbol,
                 components: [after: ["\\>"]]
               }
      end
    end

    test "invalid input returns an error tuple" do
      assert StartHairpin.new(:other) == {:error, :start_hairpin_new, :other}

      assert StartHairpin.new([:>]) == {:error, :start_hairpin_new, [:>]}

      assert StartHairpin.new(17) == {:error, :start_hairpin_new, 17}
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns the hairpin start formatted for IEx" do
      assert StartHairpin.new(">") |> inspect() == "#Satie.StartHairpin<decrescendo>"
    end
  end

  describe "attaching a hairpin to a note" do
    test "returns the correct lilypond" do
      note =
        Note.new("c'4")
        |> Satie.attach(StartHairpin.new(:crescendo), direction: :up)

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 ^ \\<
               """
               |> String.trim()
    end

    test "returns the correct lilypond with text output" do
      note =
        Note.new("c'4")
        |> Satie.attach(StartHairpin.new(:>, output: :text))

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 - \\decresc
               """
               |> String.trim()
    end
  end
end
