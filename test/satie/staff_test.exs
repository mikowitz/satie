defmodule Satie.StaffTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch, Rest, Staff, Voice}

  @c4 Note.new(Pitch.new, Duration.new)
  @d4 Note.new(Pitch.new(2, 4), Duration.new)
  @r4 Rest.new(Duration.new)
  @voice Voice.new([@c4, @d4])

  describe ".new" do
    test "/1 creates an unnamed staff with the provided music" do
      staff = Staff.new([@c4, @r4, @voice])

      assert length(staff.music) === 3
      assert is_nil(staff.name)
    end

    test "/2 creates a named staff" do
      staff = Staff.new([@c4, @r4, @voice], name: "Violin")

      assert length(staff.music) === 3
      assert staff.name === "Violin"
    end

    test "/2 ignores other options keys" do
      staff = Staff.new([@c4, @r4, @voice], mame: "Violin")

      assert length(staff.music) === 3
      assert is_nil(staff.name)
    end
  end
end
