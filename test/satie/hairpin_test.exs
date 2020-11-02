defmodule Satie.HairpinTest do
  use ExUnit.Case, async: true

  alias Satie.Hairpin

  describe "to_lilypond" do
    test "can display a crescendo" do
      cres = Hairpin.crescendo()

      assert "\\<" == Satie.to_lilypond(cres, spanner_position: :beginning)
      assert is_nil(Satie.to_lilypond(cres, spanner_position: :middle))
      assert "\\!" == Satie.to_lilypond(cres, spanner_position: :end)
    end

    test "can display a decrescendo" do
      decres = Hairpin.decrescendo(:up)

      assert "^\\>" == Satie.to_lilypond(decres, spanner_position: :beginning)
      assert is_nil(Satie.to_lilypond(decres, spanner_position: :middle))
      assert "\\!" == Satie.to_lilypond(decres, spanner_position: :end)
    end
  end
end
