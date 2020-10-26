defmodule Satie.ScoreTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Score, Staff, StaffGroup}
  doctest Score

  @c4 Note.new(Pitch.new, Duration.new)
  @d4 Note.new(Pitch.new(2, 4), Duration.new)

  @staff1 Staff.new([@c4, @d4])
  @staff2 Staff.new([@d4, @c4, @d4])
  @staff_group1 StaffGroup.new([@staff1, @staff2])
  @staff_group2 StaffGroup.new([@staff2, @staff1])

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
end

