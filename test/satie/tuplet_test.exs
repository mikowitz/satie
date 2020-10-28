defmodule Satie.TupletTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Tuplet}
  doctest Tuplet

  setup do
    c4 = Note.new(Pitch.new(), Duration.new())
    d4 = Note.new(Pitch.new(2, 4), Duration.new())
    tuplet = Tuplet.new({2, 3}, [c4, d4, c4])
    {:ok, tuplet: tuplet}
  end

  describe ".new" do
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
