defmodule Satie.Lilypond.ParserTest do
  use ExUnit.Case, async: true

  alias Satie.Lilypond.Parser

  describe "parsing a duration" do
    test "simple integer durations" do
      assert Parser.duration().("4") == {:ok, ["4", ""], ""}

      assert Parser.duration().("\\longa..") == {:ok, ["\\longa", ".."], ""}

      assert Parser.duration().("16.") == {:ok, ["16", "."], ""}
    end

    test "returns an error for unparseable strings" do
      assert Parser.duration().("longa") == {:error, "no matching parsers", "longa"}

      assert Parser.duration().("17") == {:error, "no matching parsers", "17"}
    end
  end
end
