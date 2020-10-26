defmodule Satie.TupletTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Tuplet}
  doctest Tuplet

  @c4 Note.new(Pitch.new, Duration.new)
  @d4 Note.new(Pitch.new(2, 4), Duration.new)

  describe ".new" do
    test "/2 returns a tuplet with a given multiplier and music" do
      tuplet = Tuplet.new({2,3}, [@c4, @d4, @c4])

      assert tuplet.multiplier === {2, 3}
      assert length(tuplet.music) === 3
    end
  end
end
