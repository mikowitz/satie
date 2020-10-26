defmodule Satie.ContainerTest do
  use ExUnit.Case

  alias Satie.{Container, Duration, Note, Pitch, Rest}
  doctest Container

  @c4 Note.new(Pitch.new, Duration.new)
  @r4 Rest.new(Duration.new)
  @container Container.new([@c4, @r4, @c4])

  describe ".new" do
    test "/1 returns a container with the given contents" do
      assert length(@container.music) === 3
    end
  end

  describe ".to_lilypond" do
    test "/1 returns a lilypond formatted string" do
      assert Satie.to_lilypond(@container) === """
      {
        c'4
        r4
        c'4
      }
      """ |> String.trim
    end
  end
end
