defmodule Satie.TieTest do
  use ExUnit.Case, async: true

  alias Satie.Tie

  describe "to_lilypond" do
    test "when it is tagged as the beginning of the spanner" do
      beam = Tie.new()

      assert "~" == Satie.to_lilypond(beam, spanner_position: :beginning)
    end

    test "when it is tagged as the middle of the spanner" do
      beam = Tie.new(:up)

      assert "^~" == Satie.to_lilypond(beam, spanner_position: :middle)
    end

    test "when it is tagged as the end of the spanner" do
      beam = Tie.new(:down)

      assert nil == Satie.to_lilypond(beam, spanner_position: :end)
    end
  end
end
