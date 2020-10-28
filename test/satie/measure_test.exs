defmodule Satie.MeasureTest do
  use ExUnit.Case

  alias Satie.{Duration, Measure, Note, Pitch, Rest}
  doctest Measure

  @c4 Note.new(Pitch.new(), Duration.new())
  @r4 Rest.new(Duration.new())
  @measure Measure.new({3, 4}, [@c4, @r4])

  describe ".new" do
    test "/2 accepts a time signature and music" do
      assert length(@measure.music) === 2
      assert {3, 4} === @measure.time_signature
    end
  end

  describe "Satie.to_lilypond" do
    assert Satie.to_lilypond(@measure) ===
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
