defmodule Satie.StaffTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Rest, Staff, Voice}

  setup do
    c4 = Note.new(Pitch.new(), Duration.new())
    d4 = Note.new(Pitch.new(2, 4), Duration.new())
    r4 = Rest.new(Duration.new())
    voice = Voice.new([c4, d4])
    {:ok, c4: c4, d4: d4, r4: r4, voice: voice}
  end

  describe ".new" do
    test "/1 creates an unnamed staff with the provided music", context do
      staff = Staff.new([context.c4, context.r4, context.voice])

      assert length(staff.music) === 3
      assert is_nil(staff.name)
    end

    test "/2 creates a named staff", context do
      staff = Staff.new([context.c4, context.r4, context.voice], name: "Violin")

      assert length(staff.music) === 3
      assert staff.name === "Violin"
    end

    test "/2 ignores other options keys", context do
      staff = Staff.new([context.c4, context.r4, context.voice], mame: "Violin")

      assert length(staff.music) === 3
      assert is_nil(staff.name)
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a properly formatted lilypond string for an unnamed staff", context do
      staff = Staff.new([context.c4, context.voice, context.c4], name: "Violin")

      assert Satie.to_lilypond(staff) ===
               """
               \\context Staff = "Violin" {
                 c'4
                 \\new Voice {
                   c'4
                   d'4
                 }
                 c'4
               }
               """
               |> String.trim()
    end

    test "/1 returns a properly formatted lilypond string for a named staff", context do
      staff = Staff.new([context.c4, context.voice, context.c4])

      assert Satie.to_lilypond(staff) ===
               """
               \\new Staff {
                 c'4
                 \\new Voice {
                   c'4
                   d'4
                 }
                 c'4
               }
               """
               |> String.trim()
    end
  end
end
