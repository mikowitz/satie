defmodule Satie.TimeSignatureTest do
  use ExUnit.Case, async: true

  alias Satie.TimeSignature

  test "to_lilypond" do
    assert TimeSignature.new(3, 4) |> Satie.to_lilypond() === "\\time 3/4"

    assert TimeSignature.new(6, 8) |> Satie.to_lilypond() === "\\time 6/8"
  end
end
