defmodule Satie.BarlineTest do
  use ExUnit.Case

  alias Satie.Barline

  test "to_lilypond" do
    assert Barline.new("||") |> Satie.to_lilypond() === ~s(\\bar "||")
  end
end
