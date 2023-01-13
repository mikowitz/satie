defmodule SatieTest do
  use ExUnit.Case, async: true
  import DescribeFunction
  import ExUnit.CaptureIO

  alias Satie.{Articulation, Clef, Container, Note, Tuplet, Voice}

  describe_function &Satie.show/1 do
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

  describe_function &Satie.empty/1 do
    test "returns a container with its contents cleared but all other configuration in place" do
      voice = Voice.new([Note.new("c'4"), Note.new("e'4")], name: "Voice One", simultaneous: true)

      assert Satie.empty(voice) == Voice.new([], name: "Voice One", simultaneous: true)
    end

    test "returns an error tuple when passed a non-tree-type struct" do
      assert Satie.empty(Note.new("c'4")) == {:error, :cannot_empty_non_tree, Note.new("c'4")}
    end
  end

  describe_function &Satie.attach/2 do
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

  describe_function &Satie.leaves/1 do
    test "returns a leaf as itself" do
      note = Note.new("c4")

      assert Satie.leaves(note) == [{note, []}]
    end

    test "returns a one-dimensional list of leaf elements, with Access-style paths" do
      container =
        ~w(c d e f g)
        |> Enum.map(&Note.new(&1 <> "4"))
        |> Container.new()

      assert get_in(container, [3]) == Note.new("f4")

      assert Satie.leaves(container) == [
               {Note.new("c4"), [0]},
               {Note.new("d4"), [1]},
               {Note.new("e4"), [2]},
               {Note.new("f4"), [3]},
               {Note.new("g4"), [4]}
             ]
    end

    test "handles nested containers without issue" do
      container =
        Container.new([
          Note.new("d8"),
          Tuplet.new({2, 3}, [
            Note.new("c4"),
            Note.new("d4"),
            Note.new("e4")
          ]),
          Note.new("f8")
        ])

      assert Satie.leaves(container) == [
               {Note.new("d8"), [0]},
               {Note.new("c4"), [1, 0]},
               {Note.new("d4"), [1, 1]},
               {Note.new("e4"), [1, 2]},
               {Note.new("f8"), [2]}
             ]
    end
  end

  describe_function &Satie.leaf/1 do
    test "allows Access by leaf index" do
      container =
        Container.new([
          Note.new("d8"),
          Tuplet.new({2, 3}, [
            Note.new("c4"),
            Note.new("d4"),
            Note.new("e4")
          ]),
          Note.new("f8")
        ])

      assert is_struct(get_in(container, [-2]), Tuplet)
      assert get_in(container, [Satie.leaf(-2)]) == Note.new("e4")
    end
  end
end
