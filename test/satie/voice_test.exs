defmodule Satie.VoiceTest do
  use ExUnit.Case, async: true

  alias Satie.{Container, Note, Voice}

  describe "new/1" do
    test "by default a voice has no name and is sequential" do
      voice = Voice.new([Note.new("c'4")])

      refute voice.name
      refute voice.simultaneous
    end

    test "returns the correct error if passed bad contents" do
      assert Voice.new([1, Note.new("c'4"), 3]) == {:error, :voice_new, [1, 3]}
    end
  end

  describe "new/2" do
    test "can set name and simultaneous via options on init" do
      voice = Voice.new([Container.new([Note.new("c'4")])], name: "Voice1", simultaneous: true)

      assert voice.name == "Voice1"
      assert voice.simultaneous
    end
  end

  describe "set_simultaneous/2" do
    test "sets simultaneous to the given boolean" do
      voice = Voice.new([Note.new("c'4")])
      refute voice.simultaneous

      voice = Voice.set_simultaneous(voice, true)
      assert voice.simultaneous

      voice = Voice.set_simultaneous(voice, false)
      refute voice.simultaneous
    end
  end

  describe "set_name/2" do
    test "sets the name to the given string" do
      voice = Voice.new([Note.new("c'4")])
      refute voice.name

      voice = Voice.set_name(voice, "Voice One")
      assert voice.name == "Voice One"
    end

    test "clears the name if the string is empty" do
      voice = Voice.new([Note.new("c'4")], name: "Voice One")
      assert voice.name == "Voice One"

      voice = Voice.set_name(voice, "")
      refute voice.name
    end
  end

  describe "clear_name/1" do
    test "sets the name to nil" do
      voice = Voice.new([Note.new("c'4")], name: "Voice One")
      assert voice.name == "Voice One"

      voice = Voice.clear_name(voice)
      refute voice.name
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a reasonable string output of the voice" do
      voice = Voice.new([Note.new("c'4"), Note.new("d'4")])

      assert to_string(voice) == "{ c'4 d'4 }"
    end

    test "returns a reasonable string output of a named voice" do
      voice = Voice.new([Note.new("c'4"), Note.new("d'4")], name: "Voice 1")

      assert to_string(voice) == "Voice 1 { c'4 d'4 }"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a voice formatted for IEx" do
      voice = Voice.new([Note.new("c'4"), Note.new("d'4")])

      assert inspect(voice) == "#Satie.Voice<{2}>"
    end

    test "works with a simultaneous voice" do
      voice =
        Voice.new(
          [
            Container.new([
              Note.new("c'4"),
              Note.new("d'4")
            ]),
            Container.new([
              Note.new("e'4"),
              Note.new("f'4")
            ])
          ],
          name: "Voice One",
          simultaneous: true
        )

      assert inspect(voice) == "#Satie.Voice<Voice One <<2>>>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns an unnamed voice in a lilypond format" do
      voice = Voice.new([Note.new("c'4"), Note.new("f'4")])

      assert Satie.to_lilypond(voice) ==
               """
               \\new Voice {
                 c'4
                 f'4
               }
               """
               |> String.trim()
    end

    test "returns a named voice in a lilypond format" do
      voice = Voice.new([Note.new("c'4"), Note.new("f'4")], name: "Voice One")

      assert Satie.to_lilypond(voice) ==
               """
               \\context Voice = "Voice One" {
                 c'4
                 f'4
               }
               """
               |> String.trim()
    end

    test "returns a simultaneous voice in a lilypond format" do
      voice = Voice.new([Note.new("c'4"), Note.new("f'4")], simultaneous: true)

      assert Satie.to_lilypond(voice) ==
               """
               \\new Voice <<
                 c'4
                 f'4
               >>
               """
               |> String.trim()
    end
  end
end
