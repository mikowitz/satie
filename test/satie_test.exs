defmodule SatieTest do
  use ExUnit.Case

  alias Satie.{Container, Duration, Lilypond, Note, Pitch, Rest}
  @c4 Note.new(Pitch.new(), Duration.new())
  @d4 Note.new(Pitch.new(2, 4), Duration.new())
  @r4 Rest.new(Duration.new())
  @container Container.new([@c4, @r4, @c4])

  setup_all do
    :ok = File.mkdir_p("test/saved")

    on_exit(fn -> {:ok, _} = File.rm_rf("test/saved") end)
  end

  describe ".append/2" do
    test "pushes an element to the end of the container" do
      container = Satie.append(@container, @r4)

      assert length(container.music) === 4
    end

    test "pushes multiple elements to the end of the container" do
      container = Satie.append(@container, [@r4, @c4])

      assert length(container.music) === 5
      assert List.last(container.music) === @c4
    end
  end

  describe ".insert/2" do
    test "inserts an element at the beginning of the container" do
      container = Satie.insert(@container, @r4)

      assert length(container.music) === 4
      assert List.first(container.music) === @r4
    end

    test "inserts multiple elements at the beginning of the container" do
      container = Satie.insert(@container, [@r4, @c4])

      assert length(container.music) === 5
      assert List.first(container.music) === @r4
    end
  end

  describe ".insert/3" do
    test "inserts an element at the given index" do
      container = Satie.insert(@container, @d4, 2)

      assert length(container.music) === 4
      assert container.music === [@c4, @r4, @d4, @c4]
    end
  end

  describe ".save" do
    test "creates a file with a single note at the provided location" do
      music = Note.new(Pitch.new(1, 4), Duration.new(1, 8))

      {:ok, "test/saved/single.ly"} = Satie.save(music, "test/saved/single.ly")

      {:ok, ly_file} = File.read("test/saved/single.ly")

      assert ly_file ===
               """
               \\version "#{Lilypond.lilypond_version()}"
               \\language "english"

               {
                 cs'8
               }
               """
               |> String.trim()
    end

    test "creates a file with a container at the given location" do
      music =
        Container.new([
          Note.new(Pitch.new(1, 4), Duration.new(1, 8)),
          Note.new(Pitch.new(3, 3), Duration.new(3, 8))
        ])

      {:ok, "test/saved/container.ly"} = Satie.save(music, "test/saved/container.ly")

      {:ok, ly_file} = File.read("test/saved/container.ly")

      assert ly_file ===
               """
               \\version "#{Lilypond.lilypond_version()}"
               \\language "english"

               {
                 cs'8
                 ef4.
               }
               """
               |> String.trim()
    end
  end
end
