defmodule Satie.BarlineTest do
  use ExUnit.Case, async: true

  alias Satie.Barline

  test "to_lilypond" do
    assert Barline.new("||") |> Satie.to_lilypond() === ~s(\\bar "||")
  end
end
