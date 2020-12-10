defmodule Satie.ScoreTest do
  use ExUnit.Case, async: true

  alias Satie.{Note, Rest, Score, Staff, StaffGroup}
  doctest Score

  setup do
    c4 = Note.new("c'4")
    d4 = Note.new("d'4")

    staff1 = Staff.new([c4, d4], name: "Violin")
    staff2 = Staff.new([d4, c4, d4])
    staff_group1 = StaffGroup.new([staff1, staff2], name: "Strings")
    staff_group2 = StaffGroup.new([staff2])
    {:ok, staff_group1: staff_group1, staff_group2: staff_group2, c4: c4, d4: d4}
  end

  describe ".new" do
    test "/1 creates an unnamed score with the provided music", context do
      score = Score.new([context.staff_group1, context.staff_group2])

      assert length(score.music) === 2
      assert is_nil(score.name)
    end

    test "/2 creates a named staff", context do
      score = Score.new(context.staff_group1, name: "Sonata")

      assert length(score.music) === 1
      assert score.name === "Sonata"
    end

    test "/2 ignores other options keys", context do
      score = Score.new([context.staff_group1, context.staff_group2], dame: "Sonata")

      assert length(score.music) === 2
      assert is_nil(score.name)
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a properly formatted lilypond representation of the score", context do
      score = Score.new([context.staff_group1, context.staff_group2], name: "Sonata")

      assert Satie.to_lilypond(score) ===
               """
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
               """
               |> String.trim()
    end
  end

  describe "leaves" do
    test "returns a list of all the leaves in the tree", %{c4: c4, d4: d4} = context do
      score = Score.new([context.staff_group1, context.staff_group2], name: "Sonata")

      assert [c4, d4, d4, c4, d4, d4, c4, d4] === Satie.leaves(score)
    end
  end

  describe "Access behaviour" do
    test "fetch can search by container name", context do
      score = Score.new([context.staff_group1])

      assert context.d4 === get_in(score, ["Strings", "Violin", 1])
    end

    test "get_and_update can search by container name", context do
      rest = Rest.new("r2")
      score = Score.new([context.staff_group1])

      score = update_in(score, ["Strings", "Violin", 0], fn _ -> rest end)

      assert rest === get_in(score, ["Strings", "Violin", 0])
    end

    test "pop can search by container name", context do
      score = Score.new([context.staff_group1, context.staff_group2])

      {_, score} = pop_in(score, ["Strings", 1, 1])

      assert [context.d4, context.d4] === get_in(score, ["Strings", 1]).music
    end
  end
end
