defmodule Satie.SlurTest do
  use ExUnit.Case, async: true

  alias Satie.Slur

  describe "to_lilypond" do
    test "when it is tagged as the beginning of the spanner" do
      beam = Slur.new(:down)

      assert "_(" == Satie.to_lilypond(beam, spanner_position: :beginning)
    end

    test "when it is tagged as the middle of the spanner" do
      beam = Slur.new()

      assert nil == Satie.to_lilypond(beam, spanner_position: :middle)
    end

    test "when it is tagged as the end of the spanner" do
      beam = Slur.new(:up)

      assert ")" == Satie.to_lilypond(beam, spanner_position: :end)
    end
  end
end
