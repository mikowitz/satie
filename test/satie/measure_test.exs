defmodule Satie.MeasureTest do
  use ExUnit.Case, async: true

  alias Satie.{Measure, Note, Rest}
  doctest Measure

  setup do
    c4 = Note.new("c'4")
    r4 = Rest.new("r4")
    {:ok, measure: Measure.new({3, 4}, [c4, r4])}
  end

  describe ".new" do
    test "/1 accepts a lilypond string" do
      measure = Measure.new("{ \\time 3/16 c'8 d'8 e'8 }")
      assert {3, 16} == measure.time_signature
    end

    test "/2 accepts a time signature and music", %{measure: measure} do
      assert length(measure.music) === 2
      assert {3, 4} === measure.time_signature
    end
  end

  describe "Satie.to_lilypond" do
    test "/1 returns a properly formatted lilypond representation of the measure", context do
      assert Satie.to_lilypond(context.measure) ===
               """
               {
                 \\time 3/4
                 c'4
                 r4
                 |
               }
               """
               |> String.trim()
    end
  end
end
