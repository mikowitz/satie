defmodule Satie.VoiceTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Rest, Voice}
  doctest Voice

  @c4 Note.new(Pitch.new, Duration.new)
  @d4 Note.new(Pitch.new(2, 4), Duration.new)
  @r4 Rest.new(Duration.new)
  @voice Voice.new([@c4])
  @named_voice Voice.new([@c4, @r4], name: "Soprano")
  @unnamed_voice Voice.new([@c4], nome: "Alto")

  describe ".new" do
    test "/1 creates an unnamed voice with the provided music" do
      assert length(@voice.music) === 1
      assert is_nil(@voice.name)
    end

    test "/2 creates a named voice" do
      assert length(@named_voice.music) === 2
      assert @named_voice.name === "Soprano"
    end

    test "/2 ignores other options keys" do
      assert length(@unnamed_voice.music) === 1
      assert is_nil(@unnamed_voice.name)
    end
  end

  describe ".append/2" do
    test "pushes an element to the end of the voice" do
      voice = Voice.append(@voice, @r4)

      assert length(voice.music) === 2
    end

    test "pushes multiple elements to the end of the voice" do
      voice = Voice.append(@voice, [@r4, @c4])

      assert length(voice.music) === 3
      assert List.last(voice.music) === @c4
    end
  end

  describe ".insert/2" do
    test "inserts an element at the beginning of the voice" do
      voice = Voice.insert(@voice, @r4)

      assert length(voice.music) === 2
      assert List.first(voice.music) === @r4
    end

    test "inserts multiple elements at the beginning of the voice" do
      voice = Voice.insert(@voice, [@r4, @c4])

      assert length(voice.music) === 3
      assert List.first(voice.music) === @r4
    end
  end

  describe ".insert/3" do
    test "inserts an element at the given index" do
      voice = Voice.insert(@voice, @d4, 2)

      assert length(voice.music) === 2
      assert voice.music === [@c4, @d4]
    end
  end
end
