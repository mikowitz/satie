defmodule Satie.StaffGroupTest do
  use ExUnit.Case, async: true

  alias Satie.{Note, Staff, StaffGroup}

  describe "new/1" do
    test "by default a staff group has no name and is simultaneous" do
      staff_group = StaffGroup.new([Note.new("c'4")])

      refute staff_group.name
      assert staff_group.simultaneous
    end

    test "returns the correct error if passed bad contents" do
      assert StaffGroup.new([1, Note.new("c'4"), 3]) == {:error, :staff_group_new, [1, 3]}
    end
  end

  describe "new/2" do
    test "can set name and simultaneous via options" do
      staff_group = StaffGroup.new([Note.new("c'4")], name: "Strings", simultaneous: false)

      assert staff_group.name == "Strings"
      refute staff_group.simultaneous
    end
  end

  describe "set_simultaneous/2" do
    test "sets simultaneous to the given boolean" do
      staff_group = StaffGroup.new()
      assert staff_group.simultaneous

      staff_group = StaffGroup.set_simultaneous(staff_group, false)
      refute staff_group.simultaneous

      staff_group = StaffGroup.set_simultaneous(staff_group, true)
      assert staff_group.simultaneous
    end
  end

  describe "set_name/2" do
    test "sets the name to the given string" do
      staff_group = StaffGroup.new()
      refute staff_group.name

      staff_group = StaffGroup.set_name(staff_group, "Winds")
      assert staff_group.name == "Winds"
    end

    test "clears the name if the string is empty" do
      staff_group = StaffGroup.new([], name: "Brass")
      assert staff_group.name == "Brass"

      staff_group = StaffGroup.set_name(staff_group, "")
      refute staff_group.name
    end
  end

  describe "clear_name/1" do
    test "sets the name to nil" do
      staff_group = StaffGroup.new([], name: "Percussion")
      assert staff_group.name == "Percussion"

      staff_group = StaffGroup.clear_name(staff_group)
      refute staff_group.name
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a reasonable representation of the staff group" do
      staff_group =
        StaffGroup.new(
          [
            Staff.new([Note.new("c'4")], name: "Violin One"),
            Staff.new([Note.new("d'4")], name: "Violin Two"),
            Staff.new([Note.new("e'4")], name: "Viola"),
            Staff.new([Note.new("f'4")], name: "Cello")
          ],
          name: "Strings"
        )

      assert to_string(staff_group) ==
               "Strings << Violin One { c'4 } Violin Two { d'4 } Viola { e'4 } Cello { f'4 } >>"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns the staff group formatted for IEx" do
      staff_group =
        StaffGroup.new(
          [
            Staff.new([Note.new("c'4")], name: "Violin One"),
            Staff.new([Note.new("d'4")], name: "Violin Two"),
            Staff.new([Note.new("e'4")], name: "Viola"),
            Staff.new([Note.new("f'4")], name: "Cello")
          ],
          name: "Strings"
        )

      assert inspect(staff_group) == "#Satie.StaffGroup<Strings <<4>>>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns a staff group formatted properly for Lilypond" do
      staff_group =
        StaffGroup.new(
          [
            Staff.new([Note.new("c'4")], name: "Violin One"),
            Staff.new([Note.new("e'4")], name: "Viola")
          ],
          name: "Strings"
        )

      assert Satie.to_lilypond(staff_group) ==
               """
               \\context StaffGroup = "Strings" <<
                 \\context Staff = "Violin One" {
                   c'4
                 }
                 \\context Staff = "Viola" {
                   e'4
                 }
               >>
               """
               |> String.trim()
    end
  end
end
