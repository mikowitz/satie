defmodule Satie.TupletTest do
  use ExUnit.Case, async: true

  alias Satie.{Note, Pitch, Tuplet}
  doctest Tuplet

  setup do
    c4 = Note.new("c'4")
    d4 = Note.new("d'4")
    tuplet = Tuplet.new({2, 3}, [c4, d4, c4])
    {:ok, tuplet: tuplet}
  end

  describe ".new" do
    test "/1 accepts a lilypond string" do
      tuplet = Tuplet.new("\\tuplet 3/2 { c'4 d'4 e'4 }")

      assert {2, 3} == tuplet.multiplier
      [c, d, e] = tuplet.music

      assert Pitch.new(0, 4) == c.written_pitch
      assert Pitch.new(2, 4) == d.written_pitch
      assert Pitch.new(4, 4) == e.written_pitch
    end

    test "/2 returns a tuplet with a given multiplier and music", context do
      assert context.tuplet.multiplier === {2, 3}
      assert length(context.tuplet.music) === 3
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a formatted lilypond string of the tuplet", context do
      assert Satie.to_lilypond(context.tuplet) ===
               """
               \\tuplet 3/2 {
                 c'4
                 d'4
                 c'4
               }
               """
               |> String.trim()
    end
  end
end
