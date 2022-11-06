defmodule Satie.ContainerTest do
  use ExUnit.Case, async: true

  alias Satie.{Container, Note}

  describe inspect(&Container.new/1) do
    test "can create an empty container" do
      assert Container.new() == %Container{contents: []}
    end

    test "can create a container with musical contents" do
      container = Container.new([Note.new("c'4")])
      assert length(container.contents) == 1
    end

    test "containers can be nested" do
      container =
        Container.new([
          Container.new([
            Note.new("c'4"),
            Note.new("d'4")
          ])
        ])

      assert length(container.contents) == 1
    end

    test "container contents must be Lilypond-able" do
      assert Container.new([Rest, Note.new("c'4"), :hello]) ==
               {:error, :container_new, [Rest, :hello]}
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a simple string output of the container" do
      container =
        Container.new([
          Note.new("c'4"),
          Note.new("d'4")
        ])

      assert to_string(container) == "{ c'4 d'4 }"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a container formatted for IEx" do
      container =
        Container.new([
          Note.new("c'4"),
          Note.new("d'4")
        ])

      assert inspect(container) == "#Satie.Container<{ c'4 d'4 }>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns valid Lilypond output for a container" do
      container =
        Container.new([
          Note.new("c'4"),
          Note.new("d'4")
        ])

      assert Satie.to_lilypond(container) ==
               """
               {
                 c'4
                 d'4
               }
               """
               |> String.trim()
    end

    test "returns valid Lilypond output for nested containers" do
      container =
        Container.new([
          Container.new([
            Note.new("c'4"),
            Note.new("d'4")
          ])
        ])

      assert Satie.to_lilypond(container) ==
               """
               {
                 {
                   c'4
                   d'4
                 }
               }
               """
               |> String.trim()
    end
  end

  describe "Access" do
    setup do
      inner =
        Container.new([
          Note.new("c'4"),
          Note.new("d'4")
        ])

      container = Container.new([inner])

      {:ok, container: container, inner: inner}
    end

    test "[]", %{container: container, inner: inner} do
      assert container[0] == inner

      assert container[0][1] == Note.new("d'4")

      refute container[0][2]
    end

    test "update_in", %{container: container} do
      new_container =
        update_in(container, [0], fn inner ->
          new_contents =
            Enum.map(inner.contents, fn note ->
              %{note | written_duration: Satie.Duration.new(1, 8)}
            end)

          %{inner | contents: new_contents}
        end)

      assert new_container ==
               Container.new([
                 Container.new([
                   Note.new("c'8"),
                   Note.new("d'8")
                 ])
               ])
    end

    test "pop", %{container: container} do
      {old_note, new_container} = pop_in(container, [0, 1])

      assert old_note == Note.new("d'4")

      assert new_container ==
               Container.new([
                 Container.new([
                   Note.new("c'4")
                 ])
               ])
    end
  end
end
