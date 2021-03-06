defmodule Satie.ContainerTest do
  use ExUnit.Case, async: true

  alias Satie.{Beam, Container, Note, Rest, Voice}
  doctest Container

  setup do
    c4 = Note.new("c'4")
    d4 = Note.new("d'4")
    r4 = Rest.new("r4")
    {:ok, container: Container.new([c4, r4, d4]), c4: c4, d4: d4, r4: r4}
  end

  describe ".new" do
    test "/1 accepts a lilypond string" do
      container = Container.new("{ c'4 d'4 ef'8. d16 }")

      assert length(container.music) == 4
      assert [0, 2, 3, 2] == container.music |> Enum.map(& &1.written_pitch.pitch_class_index)
    end

    test "/1 returns a container with the given contents", context do
      assert length(context.container.music) === 3
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a lilypond formatted string", context do
      assert Satie.to_lilypond(context.container) ===
               """
               {
                 c'4
                 r4
                 d'4
               }
               """
               |> String.trim()
    end

    test "/1 returns a container with simultaneous voices", %{c4: c4, d4: d4, r4: r4} do
      container =
        Container.new(
          [
            Voice.new([c4, d4]),
            Voice.new([r4, c4, d4])
          ],
          simultaneous: true
        )

      assert Satie.to_lilypond(container) ===
               """
               <<
                 \\new Voice {
                   c'4
                   d'4
                 }
                 \\new Voice {
                   r4
                   c'4
                   d'4
                 }
               >>
               """
               |> String.trim()
    end

    test "with a spanner", context do
      beam = Beam.new()

      {_, container} = Satie.attach_spanner(context.container, beam, 0..2)

      assert Satie.to_lilypond(container) ===
               """
               {
                 c'4
                   [
                 r4
                 d'4
                   ]
               }
               """
               |> String.trim()
    end
  end

  describe "Access behaviour" do
    test "fetch/2 fetches by numeric index", context do
      assert context.c4 === context.container[0]

      assert context.d4 == get_in(context.container, [2])
    end

    test "fetch/2 fetches by ref", context do
      assert context.r4 === context.container[context.r4.id]
    end

    test "fetch/2 fetches by item", context do
      assert context.d4 === context.container[context.d4]
    end

    test "get_and_update/3 works by numeric index", context do
      container = update_in(context.container, [0], fn _ -> context.d4 end)

      assert context.d4 === container[0]
    end

    test "get_and_update/3 works by ref", context do
      r2 = Rest.new("r2")
      container = update_in(context.container, [context.r4.id], fn _ -> r2 end)

      assert r2 === container[1]
    end

    test "get_and_update/3 fetches by item", context do
      r2 = Rest.new("r2")

      container = update_in(context.container, [context.d4], fn _ -> r2 end)

      assert r2 === container[2]
    end

    test "pop/2 works by numeric index", context do
      {_, container} = pop_in(context.container, [1])

      assert [context.c4, context.d4] === container.music
    end

    test "pop/2 works by reference", context do
      {_, container} = pop_in(context.container, [context.c4.id])

      assert [context.r4, context.d4] === container.music
    end

    test "pop/2 works by item", context do
      {_, container} = pop_in(context.container, [context.d4])

      assert [context.c4, context.r4] === container.music
    end
  end
end
