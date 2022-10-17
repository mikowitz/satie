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
end
