defmodule Satie.ScoreTest do
  use ExUnit.Case, async: true

  alias Satie.{Note, Score, Staff, StaffGroup}

  describe "new/1" do
    test "by default a score has no name and is simultaneous" do
      score = Score.new([Staff.new([Note.new("c'4")])])

      refute score.name
      assert score.simultaneous
    end

    test "returns the correct error if passed bad contents" do
      assert Score.new([1, Note.new("c'4"), 3]) == {:error, :score_new, [1, 3]}
    end
  end

  describe "new/2" do
    test "can set name and simultaneous via options" do
      score = Score.new([Staff.new([Note.new("c'4")])], name: "A Piece", simultaneous: false)

      assert score.name == "A Piece"
      refute score.simultaneous
    end
  end

  describe "set_simultaneous/2" do
    test "sets simultaneous to the given boolean" do
      score = Score.new()
      assert score.simultaneous

      score = Score.set_simultaneous(score, false)
      refute score.simultaneous

      score = Score.set_simultaneous(score, true)
      assert score.simultaneous
    end
  end

  describe "set_name/2" do
    test "sets the name to the given string" do
      score = Score.new()
      refute score.name

      score = Score.set_name(score, "Winds")
      assert score.name == "Winds"
    end

    test "clears the name if the string is empty" do
      score = Score.new([], name: "Brass")
      assert score.name == "Brass"

      score = Score.set_name(score, "")
      refute score.name
    end
  end

  describe "clear_name/1" do
    test "sets the name to nil" do
      score = Score.new([], name: "Percussion")
      assert score.name == "Percussion"

      score = Score.clear_name(score)
      refute score.name
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a reasonable representation of the score" do
      score =
        Score.new(
          [
            StaffGroup.new(
              [
                Staff.new([Note.new("c'4")], name: "Violin One"),
                Staff.new([Note.new("d'4")], name: "Violin Two")
              ],
              name: "Violins"
            ),
            Staff.new([Note.new("e'4")], name: "Viola"),
            Staff.new([Note.new("f'4")], name: "Cello")
          ],
          name: "Ensemble"
        )

      assert to_string(score) ==
               "Ensemble << Violins << Violin One { c'4 } Violin Two { d'4 } >> Viola { e'4 } Cello { f'4 } >>"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns the score formatted for IEx" do
      score =
        Score.new(
          [
            StaffGroup.new(
              [
                Staff.new([Note.new("c'4")], name: "Violin One"),
                Staff.new([Note.new("d'4")], name: "Violin Two")
              ],
              name: "Violins"
            ),
            Staff.new([Note.new("e'4")], name: "Viola"),
            Staff.new([Note.new("f'4")], name: "Cello")
          ],
          name: "Ensemble"
        )

      assert inspect(score) == "#Satie.Score<Ensemble <<3>>>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns a score formatted properly for Lilypond" do
      score =
        Score.new(
          [
            StaffGroup.new(
              [
                Staff.new([Note.new("c'4")], name: "Violin One"),
                Staff.new([Note.new("d'4")], name: "Violin Two")
              ],
              name: "Violins"
            ),
            Staff.new([Note.new("e'4")], name: "Viola"),
            Staff.new([Note.new("f'4")], name: "Cello")
          ],
          name: "Ensemble"
        )

      assert Satie.to_lilypond(score) ==
               """
               \\context Score = "Ensemble" <<
                 \\context StaffGroup = "Violins" <<
                   \\context Staff = "Violin One" {
                     c'4
                   }
                   \\context Staff = "Violin Two" {
                     d'4
                   }
                 >>
                 \\context Staff = "Viola" {
                   e'4
                 }
                 \\context Staff = "Cello" {
                   f'4
                 }
               >>
               """
               |> String.trim()
    end
  end
end
