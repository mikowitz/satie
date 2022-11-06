defmodule Satie.StaffTest do
  use ExUnit.Case, async: true

  alias Satie.{Container, Note, Staff, Voice}

  describe "new/1" do
    test "by default a staff has no name and is sequential" do
      staff = Staff.new([Note.new("c'4")])

      refute staff.name
      refute staff.simultaneous
    end

    test "returns the correct error if passed bad contents" do
      assert Staff.new([1, Note.new("c'4"), 3]) == {:error, :staff_new, [1, 3]}
    end
  end

  describe "new/2" do
    test "can set name and simultaneous via options" do
      staff = Staff.new([Container.new([Note.new("c'4")])], name: "Staff One", simultaneous: true)

      assert staff.name == "Staff One"
      assert staff.simultaneous
    end
  end

  describe "set_simultaneous/2" do
    test "sets simultaneous to the given boolean" do
      staff = Staff.new()
      refute staff.simultaneous

      staff = Staff.set_simultaneous(staff, true)
      assert staff.simultaneous

      staff = Staff.set_simultaneous(staff, false)
      refute staff.simultaneous
    end
  end

  describe "set_name/2" do
    test "sets the name to the given string" do
      staff = Staff.new()
      refute staff.name

      staff = Staff.set_name(staff, "Staff Two")
      assert staff.name == "Staff Two"
    end

    test "clears the name if the string is empty" do
      staff = Staff.new([], name: "Staff Three")
      assert staff.name == "Staff Three"

      staff = Staff.set_name(staff, "")
      refute staff.name
    end
  end

  describe inspect(&Staff.clear_name/1) do
    test "sets the name to nil" do
      staff = Staff.new([], name: "Staff Three")
      assert staff.name == "Staff Three"

      staff = Staff.clear_name(staff)
      refute staff.name
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a reasonable representation of the staff" do
      staff = Staff.new([Container.new([Note.new("c'4")])], name: "Staff One")

      assert to_string(staff) == "Staff One { { c'4 } }"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns the staff formatted for IEx" do
      staff = Staff.new([Container.new([Note.new("c'4"), Note.new("d'4")])], name: "Staff One")

      assert inspect(staff) == "#Satie.Staff<Staff One {1}>"
    end

    test "returns a simultaneous staff formatted for IEx" do
      staff =
        Staff.new(
          [
            Container.new([
              Note.new("c'4")
            ]),
            Container.new([
              Note.new("d'4")
            ])
          ],
          simultaneous: true
        )

      assert inspect(staff) == "#Satie.Staff<<<2>>>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns a staff formatted properly for Lilypond" do
      staff = Staff.new([Note.new("c'4")])

      assert Satie.to_lilypond(staff) ==
               """
               \\new Staff {
                 c'4
               }
               """
               |> String.trim()
    end

    test "returns a named staff formatted properly for Lilypond" do
      staff = Staff.new([Note.new("c'4")], name: "Staff One")

      assert Satie.to_lilypond(staff) ==
               """
               \\context Staff = "Staff One" {
                 c'4
               }
               """
               |> String.trim()
    end

    test "correctly formats a simultaneous staff" do
      staff =
        Staff.new(
          [
            Container.new([Note.new("c'4")]),
            Container.new([Note.new("d'4")])
          ],
          name: "Staff Two",
          simultaneous: true
        )

      assert Satie.to_lilypond(staff) ==
               """
               \\context Staff = "Staff Two" <<
                 {
                   c'4
                 }
                 {
                   d'4
                 }
               >>
               """
               |> String.trim()
    end
  end

  describe "Access" do
    setup do
      staff =
        Staff.new([
          Voice.new(
            [Note.new("c'4"), Note.new("d'4")],
            name: "Voice One"
          ),
          Voice.new(
            [Note.new("e'4"), Note.new("f'4")],
            name: "Voice Two"
          )
        ])

      {:ok, staff: staff}
    end

    test "[] works with indices", %{staff: staff} do
      assert staff[1][0] == Note.new("e'4")
    end

    test "[] works with named trees", %{staff: staff} do
      assert staff["Voice One"][1] == Note.new("d'4")
    end

    test "update_in works with indices", %{staff: staff} do
      new_staff =
        update_in(staff, [1], fn _voice ->
          Voice.new([Note.new("bqf2")], name: "New Voice Two")
        end)

      assert new_staff ==
               Staff.new([
                 Voice.new(
                   [Note.new("c'4"), Note.new("d'4")],
                   name: "Voice One"
                 ),
                 Voice.new(
                   [Note.new("bqf2")],
                   name: "New Voice Two"
                 )
               ])
    end

    test "update_in works with named trees", %{staff: staff} do
      new_staff =
        update_in(staff, ["Voice Two"], fn _voice ->
          Voice.new([Note.new("bqf2")], name: "New Voice Two")
        end)

      assert new_staff[1] ==
               Voice.new(
                 [Note.new("bqf2")],
                 name: "New Voice Two"
               )
    end

    test "pop with indices", %{staff: staff} do
      {old_note, new_staff} = pop_in(staff, [0, 0])

      assert old_note == Note.new("c'4")

      assert new_staff[0] ==
               Voice.new(
                 [
                   Note.new("d'4")
                 ],
                 name: "Voice One"
               )
    end

    test "pop with named trees", %{staff: staff} do
      {old_voice, new_staff} = pop_in(staff, ["Voice One"])

      assert old_voice.name == "Voice One"

      assert new_staff[0] ==
               Voice.new(
                 [
                   Note.new("e'4"),
                   Note.new("f'4")
                 ],
                 name: "Voice Two"
               )
    end
  end
end
