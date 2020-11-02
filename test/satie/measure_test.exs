defmodule Satie.MeasureTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Measure, Note, Pitch, Rest}
  doctest Measure

  setup do
    c4 = Note.new(Pitch.new(), Duration.new())
    r4 = Rest.new(Duration.new())
    {:ok, measure: Measure.new({3, 4}, [c4, r4])}
  end

  describe ".new" do
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
