defmodule Satie.VoiceTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Rest, Voice}
  doctest Voice

  @c4 Note.new(Pitch.new, Duration.new)
  @r4 Rest.new(Duration.new)
  @voice Voice.new([@c4])
  @named_voice Voice.new([@c4, @r4], name: "Soprano")
  @unnamed_voice Voice.new([@c4], nome: "Alto")

  describe ".new" do
    test "/1 creates an unnamed voice with the provided music" do
      assert length(@voice.music) === 1
      assert is_nil(@voice.name)
    end

    test "/2 creates a named voice" do
      assert length(@named_voice.music) === 2
      assert @named_voice.name === "Soprano"
    end

    test "/2 ignores other options keys" do
      assert length(@unnamed_voice.music) === 1
      assert is_nil(@unnamed_voice.name)
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a properly formatted lilypond string for a named voice" do
      assert Satie.to_lilypond(@named_voice) === """
      \\context Voice = "Soprano" {
        c'4
        r4
      }
      """ |> String.trim
    end

    test "/1 returns a properly formatted lilypond string for an unnamed voice" do
      assert Satie.to_lilypond(@unnamed_voice) === """
      \\new Voice {
        c'4
      }
      """ |> String.trim
    end
  end
end
