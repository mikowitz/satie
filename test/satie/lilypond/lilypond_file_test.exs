defmodule Satie.Lilypond.LilypondFileTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Satie.{Container, Lilypond.LilypondFile, Note, Timespan, TimespanList}

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

    test "can take a set of options to pass to Satie.to_lilypond" do
      timespan = Timespan.new(5, 10)

      file = LilypondFile.from(timespan, range: 0..20)

      assert file.lilypond_options == [range: 0..20]
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

    test "saves the contents using the given options" do
      timespan_list =
        TimespanList.new([
          Timespan.new(0, 16),
          Timespan.new(5, 12),
          Timespan.new(-2, 8),
          Timespan.new(15, 20),
          Timespan.new(24, 30)
        ])

      file =
        LilypondFile.from(timespan_list, range: -10..50)
        |> LilypondFile.save("test/lilypond_file_show_timespan_list.ly")

      {:ok, lilypond} = File.read(file.source_path)

      {:ok, timespan_list_content} = File.read("test/files/timespan_list_ranged.ly")

      assert lilypond ==
               """
               \\version "#{Satie.lilypond_version()}"
               \\language "english"

               #{timespan_list_content}
               """
               |> String.trim()

      :ok = File.rm(file.source_path)
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
