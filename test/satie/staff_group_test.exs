defmodule Satie.StaffGroupTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Staff, StaffGroup}
  doctest StaffGroup

  @c4 Note.new(Pitch.new, Duration.new)
  @d4 Note.new(Pitch.new(2, 4), Duration.new)

  @staff1 Staff.new([@c4, @d4], name: "Violin")
  @staff2 Staff.new([@d4, @c4, @d4], name: "Cello")

  describe ".new" do
    test "/1 creates an unnamed staff group with the provided music" do
      staff_group = StaffGroup.new([@staff1, @staff2])

      assert length(staff_group.music) === 2
      assert is_nil(staff_group.name)
    end

    test "/2 creates a named staff" do
      staff_group = StaffGroup.new([@staff1, @staff2], name: "Strings")

      assert length(staff_group.music) === 2
      assert staff_group.name === "Strings"
    end

    test "/2 ignores other options keys" do
      staff_group = StaffGroup.new([@staff1, @staff2], same: "Strings")

      assert length(staff_group.music) === 2
      assert is_nil(staff_group.name)
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a properly formatted lilypond string for a named voice" do
      staff_group = StaffGroup.new([@staff1, @staff2], name: "Strings")
      assert Satie.to_lilypond(staff_group) === """
      \\context StaffGroup = "Strings" <<
        \\context Staff = "Violin" {
          c'4
          d'4
        }
        \\context Staff = "Cello" {
          d'4
          c'4
          d'4
        }
      >>
      """ |> String.trim
    end
  end
end
