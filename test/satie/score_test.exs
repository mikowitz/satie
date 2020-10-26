defmodule Satie.ScoreTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Score, Staff, StaffGroup}
  doctest Score

  @c4 Note.new(Pitch.new, Duration.new)
  @d4 Note.new(Pitch.new(2, 4), Duration.new)

  @staff1 Staff.new([@c4, @d4], name: "Violin")
  @staff2 Staff.new([@d4, @c4, @d4])
  @staff_group1 StaffGroup.new([@staff1, @staff2], name: "Strings")
  @staff_group2 StaffGroup.new([@staff2])

  describe ".new" do
    test "/1 creates an unnamed score with the provided music" do
      score = Score.new([@staff_group1, @staff_group2])

      assert length(score.music) === 2
      assert is_nil(score.name)
    end

    test "/2 creates a named staff" do
      score = Score.new(@staff_group1, name: "Sonata")

      assert length(score.music) === 1
      assert score.name === "Sonata"
    end

    test "/2 ignores other options keys" do
      staff_group = Score.new([@staff_group1, @staff_group2], dame: "Sonata")

      assert length(staff_group.music) === 2
      assert is_nil(staff_group.name)
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a properly formatted lilypond representation of the score" do
      score = Score.new([@staff_group1, @staff_group2], name: "Sonata")
      assert Satie.to_lilypond(score) === """
      \\context Score = "Sonata" <<
        \\context StaffGroup = "Strings" <<
          \\context Staff = "Violin" {
            c'4
            d'4
          }
          \\new Staff {
            d'4
            c'4
            d'4
          }
        >>
        \\new StaffGroup <<
          \\new Staff {
            d'4
            c'4
            d'4
          }
        >>
      >>
      """ |> String.trim
    end
  end
end

