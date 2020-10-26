defmodule Satie.ContainerTest do
  use ExUnit.Case

  alias Satie.{Container, Duration, Note, Pitch, Rest}
  doctest Container

  @c4 Note.new(Pitch.new, Duration.new)
  @d4 Note.new(Pitch.new(2, 4), Duration.new)
  @r4 Rest.new(Duration.new)
  @container Container.new([@c4, @r4, @c4])

  describe ".new" do
    test "/1 returns a container with the given contents" do
      assert length(@container.music) === 3
    end
  end

  describe ".append/2" do
    test "pushes an element to the end of the container" do
      container = Container.append(@container, @r4)

      assert length(container.music) === 4
    end

    test "pushes multiple elements to the end of the container" do
      container = Container.append(@container, [@r4, @c4])

      assert length(container.music) === 5
      assert List.last(container.music) === @c4
    end
  end

  describe ".insert/2" do
    test "inserts an element at the beginning of the container" do
      container = Container.insert(@container, @r4)

      assert length(container.music) === 4
      assert List.first(container.music) === @r4
    end

    test "inserts multiple elements at the beginning of the container" do
      container = Container.insert(@container, [@r4, @c4])

      assert length(container.music) === 5
      assert List.first(container.music) === @r4
    end
  end

  describe ".insert/3" do
    test "inserts an element at the given index" do
      container = Container.insert(@container, @d4, 2)

      assert length(container.music) === 4
      assert container.music === [@c4, @r4, @d4, @c4]
    end
  end
end
