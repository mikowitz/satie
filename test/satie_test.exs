defmodule SatieTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Satie.{Container, Duration, Lilypond, Note, Pitch, Rest, Slur, Tuplet, Voice}

  setup do
    c4 = Note.new(Pitch.new(), Duration.new())
    d4 = Note.new(Pitch.new(2, 4), Duration.new())
    r4 = Rest.new(Duration.new())
    container = Container.new([c4, r4, c4])
    {:ok, c4: c4, d4: d4, r4: r4, container: container}
  end

  setup_all do
    :ok = File.mkdir_p("test/saved")

    on_exit(fn -> {:ok, _} = File.rm_rf("test/saved") end)
  end

  describe "attach_spanner" do
    test "can add a slur across adjacent leaves with a range" do
      container =
        Container.new([
          Voice.new(
            [
              Note.new("c4"),
              Note.new("d4")
            ],
            name: "Voice_One"
          ),
          Container.new(
            [
              Voice.new(
                [
                  Note.new("g4"),
                  Note.new("a4")
                ],
                name: "Voice_Two"
              ),
              Voice.new(
                [
                  Note.new("e4"),
                  Note.new("f4")
                ],
                name: "Voice_One"
              )
            ],
            simultaneous: true
          )
        ])

      slur = Slur.new()

      {_, container} = Satie.attach_spanner(container, slur, 0..1)

      assert Satie.to_lilypond(container) ===
               """
               {
                 \\context Voice = "Voice_One" {
                   c4
                     (
                   d4
                     )
                 }
                 <<
                   \\context Voice = "Voice_Two" {
                     g4
                     a4
                   }
                   \\context Voice = "Voice_One" {
                     e4
                     f4
                   }
                 >>
               }
               """
               |> String.trim()
    end

    test "can add a slur across non-adjacent leaves with a list of leaves" do
      container =
        Container.new([
          Voice.new(
            [
              Note.new("c4"),
              Note.new("d4")
            ],
            name: "Voice_One"
          ),
          Container.new(
            [
              Voice.new(
                [
                  Note.new("g4"),
                  Note.new("a4")
                ],
                name: "Voice_Two"
              ),
              Voice.new(
                [
                  Note.new("e4"),
                  Note.new("f4")
                ],
                name: "Voice_One"
              )
            ],
            simultaneous: true
          )
        ])

      voice_one_leaves = Satie.leaves_in(container, "Voice_One")

      assert length(voice_one_leaves) === 4

      {_, container} = Satie.attach_spanner(container, Slur.new(), voice_one_leaves)

      assert Satie.to_lilypond(container) ===
               """
               {
                 \\context Voice = "Voice_One" {
                   c4
                     (
                   d4
                 }
                 <<
                   \\context Voice = "Voice_Two" {
                     g4
                     a4
                   }
                   \\context Voice = "Voice_One" {
                     e4
                     f4
                       )
                   }
                 >>
               }
               """
               |> String.trim()
    end

    test "can add a slur across non-adjacent leaves with a list" do
      container =
        Container.new([
          Voice.new(
            [
              Note.new("c4"),
              Note.new("d4")
            ],
            name: "Voice_One"
          ),
          Container.new(
            [
              Voice.new(
                [
                  Note.new("g4"),
                  Note.new("a4")
                ],
                name: "Voice_Two"
              ),
              Voice.new(
                [
                  Note.new("e4"),
                  Note.new("f4")
                ],
                name: "Voice_One"
              )
            ],
            simultaneous: true
          )
        ])

      slur = Slur.new()

      {_, container} = Satie.attach_spanner(container, slur, [0, 1, 4, 5])

      assert Satie.to_lilypond(container) ===
               """
               {
                 \\context Voice = "Voice_One" {
                   c4
                     (
                   d4
                 }
                 <<
                   \\context Voice = "Voice_Two" {
                     g4
                     a4
                   }
                   \\context Voice = "Voice_One" {
                     e4
                     f4
                       )
                   }
                 >>
               }
               """
               |> String.trim()
    end
  end

  describe "pathed_leaves/1" do
    test "returns a leaf if given a leaf", context do
      assert context.d4 === Satie.pathed_leaves(context.d4)
    end

    test "returns a list of leaves with access paths associated when given a tree",
         %{c4: c4, r4: r4} = context do
      assert [
               {[0], c4},
               {[1], r4},
               {[2], c4}
             ] === Satie.pathed_leaves(context.container)
    end
  end

  describe "attaching/detaching spanners" do
    test "attaching a spanner" do
      [c4, d4, e4] = for i <- [0, 2, 4], do: Note.new(Pitch.new(i, 4), Duration.new())

      container = Container.new([c4, d4, e4])
      {slur, container} = Satie.attach_spanner(container, Slur.new(), 0..2)

      [c4, d4, e4] = container.music

      assert [{slur, :beginning}] == c4.spanners
      assert [{slur, :middle}] == d4.spanners
      assert [{slur, :end}] == e4.spanners

      {_, container} = Satie.detach_spanner(container, slur)

      [c4, d4, e4] = container.music

      assert [] = c4.spanners
      assert [] = d4.spanners
      assert [] = e4.spanners
    end
  end

  describe ".append/2" do
    test "pushes an element to the end of the container", context do
      container = Satie.append(context.container, context.r4)

      assert length(container.music) === 4
    end

    test "pushes multiple elements to the end of the container", context do
      container = Satie.append(context.container, [context.r4, context.c4])

      assert length(container.music) === 5
      assert List.last(container.music) === context.c4
    end
  end

  describe ".insert/2" do
    test "inserts an element at the beginning of the container", context do
      container = Satie.insert(context.container, context.r4)

      assert length(container.music) === 4
      assert List.first(container.music) === context.r4
    end

    test "inserts multiple elements at the beginning of the container", context do
      container = Satie.insert(context.container, [context.r4, context.c4])

      assert length(container.music) === 5
      assert List.first(container.music) === context.r4
    end
  end

  describe ".insert/3" do
    test "inserts an element at the given index", context do
      container = Satie.insert(context.container, context.d4, 2)

      assert length(container.music) === 4
      assert container.music === [context.c4, context.r4, context.d4, context.c4]
    end
  end

  describe ".show" do
    test "will compile and open the resulting file" do
      music = Note.new(Pitch.new(1, 4), Duration.new(1, 8))
      output = capture_io(fn -> Satie.show(music) end)
      assert Regex.match?(~r/lilypond -o (.*) \1\.ly\nopen \1\.pdf/, output)
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

  describe ".parentage" do
    test "returns the full parentage of a leaf" do
      tuplet = Tuplet.new("\\tuplet 3/2 { c'4 d'4 e'4 }")

      voice =
        Voice.new(
          [
            Note.new("c4"),
            Rest.new("r4"),
            tuplet
          ],
          name: "Voice_One"
        )

      container = Container.new([voice])

      leaves = Satie.leaves(container)
      c = Enum.at(leaves, 2)

      assert Satie.parentage(c, container) === [
               tuplet,
               voice,
               container
             ]
    end
  end
end
