defmodule Satie.StartHairpinTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.StartHairpin

  doctest StartHairpin

  describe_function &StartHairpin.new/1 do
    test "can take a lilypond string or a descriptive atom" do
      for token <- [:<, :crescendo, :cresc] do
        assert StartHairpin.new(token) == %StartHairpin{direction: :crescendo}

        assert StartHairpin.new(to_string(token)) == %StartHairpin{direction: :crescendo}
      end

      for token <- [:>, :decrescendo, :decresc] do
        assert StartHairpin.new(token) == %StartHairpin{direction: :decrescendo}

        assert StartHairpin.new(to_string(token)) == %StartHairpin{direction: :decrescendo}
      end
    end

    test "invalid input returns an error tuple" do
      assert StartHairpin.new(:other) == {:error, :start_hairpin_new, :other}

      assert StartHairpin.new([:>]) == {:error, :start_hairpin_new, [:>]}

      assert StartHairpin.new(17) == {:error, :start_hairpin_new, 17}
    end
  end

  describe_function &String.Chars.to_string/1 do
    test "returns a reasonable string representation of the hairpin start" do
      assert StartHairpin.new(">") |> to_string() == "\\>"
    end
  end

  describe_function &Inspect.inspect/2 do
    test "returns the hairpin start formatted for IEx" do
      assert StartHairpin.new(">") |> inspect() == "#Satie.StartHairpin<decrescendo>"
    end
  end

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    test "returns a valid lilypond formatting for the hairpin start" do
      assert StartHairpin.new(">") |> Satie.to_lilypond() == "\\>"
    end
  end
end
