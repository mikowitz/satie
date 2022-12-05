defmodule Satie.AttachmentTest do
  use ExUnit.Case, async: true

  alias Satie.{Articulation, Attachment, Clef, TimeSignature}

  doctest Attachment

  describe inspect(&Attachment.new/1) do
    test "sets a default position based on the attached item" do
      attachment = Attachment.new(Articulation.new("accent"))

      assert attachment.position == :after
    end
  end

  describe inspect(&Attachment.new/2) do
    test "can override an attachment's position" do
      attachment = Attachment.new(Articulation.new("accent"), position: :before)

      assert attachment.position == :before
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "defaults to no direction" do
      accent = Articulation.new("accent")
      attachment = Attachment.new(accent)

      assert Satie.to_lilypond(attachment) == "- \\accent"
    end

    test "outputs correctly for specified direction" do
      accent = Articulation.new("accent")
      attachment = Attachment.new(accent, direction: :down)

      assert Satie.to_lilypond(attachment) == "_ \\accent"
    end

    test "no direction output for an attachment that has no direction" do
      time_signature = TimeSignature.new(3, 4)
      attachment = Attachment.new(time_signature)

      assert Satie.to_lilypond(attachment) == "\\time 3/4"
    end
  end
end
