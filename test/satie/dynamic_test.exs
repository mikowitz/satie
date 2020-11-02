defmodule Satie.DynamicTest do
  use ExUnit.Case, async: true

  alias Satie.Dynamic

  test "to_lilypond" do
    assert Dynamic.new("pp") |> Satie.to_lilypond() === "\\pp"

    assert Dynamic.new("ff", :down) |> Satie.to_lilypond() === "_\\ff"

    assert Dynamic.new("mp", :up) |> Satie.to_lilypond() === "^\\mp"
  end
end
