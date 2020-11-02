defmodule Satie.VoiceTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Note, Pitch, Rest, Voice}
  doctest Voice

  setup do
    c4 = Note.new(Pitch.new(), Duration.new())
    r4 = Rest.new(Duration.new())
    voice = Voice.new([c4])
    named_voice = Voice.new([c4, r4], name: "Soprano")
    unnamed_voice = Voice.new([c4], nome: "Alto")
    {:ok, voice: voice, named_voice: named_voice, unnamed_voice: unnamed_voice}
  end

  describe ".new" do
    test "/1 creates an unnamed voice with the provided music", context do
      assert length(context.voice.music) === 1
      assert is_nil(context.voice.name)
    end

    test "/2 creates a named voice", context do
      assert length(context.named_voice.music) === 2
      assert context.named_voice.name === "Soprano"
    end

    test "/2 ignores other options keys", context do
      assert length(context.unnamed_voice.music) === 1
      assert is_nil(context.unnamed_voice.name)
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a properly formatted lilypond string for a named voice", context do
      assert Satie.to_lilypond(context.named_voice) ===
               """
               \\context Voice = "Soprano" {
                 c'4
                 r4
               }
               """
               |> String.trim()
    end

    test "/1 returns a properly formatted lilypond string for an unnamed voice", context do
      assert Satie.to_lilypond(context.unnamed_voice) ===
               """
               \\new Voice {
                 c'4
               }
               """
               |> String.trim()
    end
  end
end
