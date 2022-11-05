defmodule Satie.Lilypond.LilypondFileTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Satie.{Container, Lilypond.LilypondFile, Note}

  describe "from/1" do
    test "wraps a leaf in a Container" do
      note = Note.new("c'4")

      file = LilypondFile.from(note)

      assert is_struct(file.content, Container)
    end

    test "does not need to wrap a container" do
      container = Container.new([Note.new("c'4")])

      file = LilypondFile.from(container)

      assert is_struct(file.content, Container)
    end
  end

  describe "save/2" do
    test "saves the lilypond file to the given location" do
      container = Container.new([Note.new("c'4"), Note.new("d'4")])

      file =
        LilypondFile.from(container)
        |> LilypondFile.save("test/test.ly")

      {:ok, lilypond} = File.read(file.source_path)

      assert lilypond ==
               """
               \\version "#{Satie.lilypond_version()}"
               \\language "english"

               {
                 c'4
                 d'4
               }
               """
               |> String.trim()

      :ok = File.rm("test/test.ly")
    end
  end

  describe "show/1" do
    test "calls the configured lilypond runner" do
      note = Note.new("c'4")

      file = LilypondFile.from(note)

      output = capture_io(fn -> LilypondFile.show(file) end)

      assert Regex.match?(~r/#{Satie.lilypond_executable()} -o (.*) \1\.ly\nopen \1\.pdf/, output)
    end
  end
end
