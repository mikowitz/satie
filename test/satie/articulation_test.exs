defmodule Satie.ArticulationTest do
  use ExUnit.Case, async: true

  alias Satie.Articulation

  test "to_lilypond" do
    assert Articulation.new("accent") |> Satie.to_lilypond() === "\\accent"

    assert Articulation.new("marcato", :up) |> Satie.to_lilypond() === "^\\marcato"

    assert Articulation.new("mordent", :down) |> Satie.to_lilypond() === "_\\mordent"
  end
end
