defmodule Satie.ToLilypondTest do
  use ExUnit.Case, async: true

  test ".to_lilypond/1 falls back to Any" do
    assert Satie.ToLilypond.to_lilypond(1) === "1"
  end
end
