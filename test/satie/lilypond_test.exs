defmodule Satie.LilypondTest do
  use ExUnit.Case

  alias Satie.{Container, Duration, Note, Pitch, Lilypond}

  setup_all do
    :ok = File.mkdir_p("test/saved")

    on_exit(fn -> {:ok, _} = File.rm_rf("test/saved") end)
  end

  describe ".save" do
    test "creates a file with a single note at the provided location" do
      music = Note.new(Pitch.new(1,4), Duration.new(1,8))

      {:ok, "test/saved/single.ly"} = Lilypond.save(music, "test/saved/single.ly")

      {:ok, ly_file} = File.read("test/saved/single.ly")

      assert ly_file === """
      \\version "#{Lilypond.lilypond_version}"
      \\language "english"

      {
        cs'8
      }
      """ |> String.trim
    end

    test "creates a file with a container at the given location" do
      music = Container.new([
        Note.new(Pitch.new(1,4), Duration.new(1,8)),
        Note.new(Pitch.new(3,3), Duration.new(3,8))
      ])

      {:ok, "test/saved/container.ly"} = Lilypond.save(music, "test/saved/container.ly")

      {:ok, ly_file} = File.read("test/saved/container.ly")

      assert ly_file === """
      \\version "#{Lilypond.lilypond_version}"
      \\language "english"

      {
        cs'8
        ef4.
      }
      """ |> String.trim

    end
  end
end
