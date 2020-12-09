defmodule Satie.PianoStaffTest do
  use ExUnit.Case, async: true

  alias Satie.{Container, PianoStaff, Staff}

  describe ".to_lilypond" do
    test "/1 returns a properly formatted lilypond representation of the piano staff" do
      piano_staff =
        PianoStaff.new(
          [
            Staff.new(
              [
                Container.new("{ c'4 d'4 }")
              ],
              name: "Upper"
            ),
            Staff.new(
              [
                Container.new("{ a4 g4 }")
              ],
              name: "Lower"
            )
          ],
          name: "Piano"
        )

      assert Satie.to_lilypond(piano_staff) ===
               """
               \\context PianoStaff = "Piano" <<
                 \\context Staff = "Upper" {
                   {
                     c'4
                     d'4
                   }
                 }
                 \\context Staff = "Lower" {
                   {
                     a4
                     g4
                   }
                 }
               >>
               """
               |> String.trim()
    end
  end
end
