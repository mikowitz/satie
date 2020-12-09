defmodule Satie.CommandTest do
  use ExUnit.Case, async: true

  alias Satie.Command

  test "to_lilypond" do
    assert Command.new("voiceOne") |> Satie.to_lilypond() == "\\voiceOne"
  end
end
