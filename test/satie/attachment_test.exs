defmodule Satie.AttachmentTest do
  use ExUnit.Case, async: true

  alias Satie.{Articulation, Attachment}

  doctest Attachment

  describe inspect(&Attachment.new/1) do
    test "sets a nil position based on the attached item" do
      attachment = Attachment.new(Articulation.new("accent"))

      assert attachment.position == nil
    end
  end

  describe inspect(&Attachment.new/2) do
    test "can override an attachment's position" do
      attachment = Attachment.new(Articulation.new("accent"), position: :before)

      assert attachment.position == :before
    end
  end
end
