defmodule SatieTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Satie.{Articulation, Clef, Note, Voice}

  describe "show/1" do
    test "returns an error if the input is not a lilypondable object" do
      assert Satie.show(3) == {:error, "3 cannot be formatted in Lilypond"}
    end

    test "calls the configured lilypond runner if the input is a lilypondable object" do
      note = Note.new("c'4")

      output =
        capture_io(fn ->
          file = Satie.show(note)

          {:ok, lilypond} = File.read(file.source_path)

          assert lilypond ==
                   """
                   \\version "#{Satie.lilypond_version()}"
                   \\language "english"

                   {
                     c'4
                   }
                   """
                   |> String.trim()

          :ok = File.rm(file.source_path)
        end)

      assert Regex.match?(~r/#{Satie.lilypond_executable()} -o (.*) \1\.ly\nopen \1\.pdf/, output)
    end
  end

  describe "empty/1" do
    test "returns a container with its contents cleared but all other configuration in place" do
      voice = Voice.new([Note.new("c'4"), Note.new("e'4")], name: "Voice One", simultaneous: true)

      assert Satie.empty(voice) == Voice.new([], name: "Voice One", simultaneous: true)
    end

    test "returns an error tuple when passed a non-tree-type struct" do
      assert Satie.empty(Note.new("c'4")) == {:error, :cannot_empty_non_tree, Note.new("c'4")}
    end
  end

  describe "attach/2" do
    test "can attach an articulation to a note" do
      note = Note.new("c'4")
      accent = Articulation.new("accent")

      note = Satie.attach(note, accent)

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 - \\accent
               """
               |> String.trim()
    end

    test "cannot attach duplicate articulations to the same note" do
      note = Note.new("c'4")
      accent = Articulation.new("accent")

      note = Satie.attach(note, accent)

      assert Satie.attach(note, accent) ==
               {:error, :duplicate_attachment, Articulation.new("accent")}
    end

    test "cannot attach non-articulations to a note" do
      note = Note.new("c'4")

      assert Satie.attach(note, "accent") == {:error, :not_attachable, "accent"}
    end

    test "cannot attach articulations to a non-musical type" do
      accent = Articulation.new("accent")

      assert Satie.attach("note", accent) == {:error, :cannot_attach_to, "note"}
    end

    test "some attachments go before the leaf" do
      note = Note.new("c'4")
      accent = Articulation.new("accent")
      clef = Clef.new("treble")

      note =
        Satie.attach(note, accent)
        |> Satie.attach(clef)

      assert Satie.to_lilypond(note) ==
               """
               \\clef "treble"
               c'4
                 - \\accent
               """
               |> String.trim()
    end
  end
end
