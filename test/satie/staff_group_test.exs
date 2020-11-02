defmodule Satie.StaffGroupTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Note, Pitch, Staff, StaffGroup}
  doctest StaffGroup

  setup do
    c4 = Note.new(Pitch.new(), Duration.new())
    d4 = Note.new(Pitch.new(2, 4), Duration.new())

    staff1 = Staff.new([c4, d4], name: "Violin")
    staff2 = Staff.new([d4, c4, d4], name: "Cello")

    {:ok, staff1: staff1, staff2: staff2}
  end

  describe ".new" do
    test "/1 creates an unnamed staff group with the provided music", context do
      staff_group = StaffGroup.new([context.staff1, context.staff2])

      assert length(staff_group.music) === 2
      assert is_nil(staff_group.name)
    end

    test "/2 creates a named staff", context do
      staff_group = StaffGroup.new([context.staff1, context.staff2], name: "Strings")

      assert length(staff_group.music) === 2
      assert staff_group.name === "Strings"
    end

    test "/2 ignores other options keys", context do
      staff_group = StaffGroup.new([context.staff1, context.staff2], same: "Strings")

      assert length(staff_group.music) === 2
      assert is_nil(staff_group.name)
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a properly formatted lilypond string for a named voice", context do
      staff_group = StaffGroup.new([context.staff1, context.staff2], name: "Strings")

      assert Satie.to_lilypond(staff_group) ===
               """
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
               """
               |> String.trim()
    end
  end
end
