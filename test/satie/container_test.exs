defmodule Satie.ContainerTest do
  use ExUnit.Case

  alias Satie.{Container, Duration, Note, Pitch, Rest}
  doctest Container

  setup do
    c4 = Note.new(Pitch.new(), Duration.new())
    r4 = Rest.new(Duration.new())
    {:ok, container: Container.new([c4, r4, c4])}
  end

  describe ".new" do
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
                 c'4
               }
               """
               |> String.trim()
    end
  end
end
