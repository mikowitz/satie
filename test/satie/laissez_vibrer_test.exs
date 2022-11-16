defmodule Satie.LaissezVibrerTest do
  use ExUnit.Case, async: true

  alias Satie.LaissezVibrer

  doctest LaissezVibrer

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of an laissez vibrer tie" do
      assert LaissezVibrer.new() |> to_string() == "- \\laissezVibrer"

      assert LaissezVibrer.new(:up) |> to_string() == "^ \\laissezVibrer"

      assert LaissezVibrer.new(:down) |> to_string() == "_ \\laissezVibrer"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a laissez vibrer tie" do
      assert LaissezVibrer.new() |> Satie.to_lilypond() == "- \\laissezVibrer"

      assert LaissezVibrer.new(:up) |> Satie.to_lilypond() == "^ \\laissezVibrer"

      assert LaissezVibrer.new(:down) |> Satie.to_lilypond() == "_ \\laissezVibrer"
    end
  end
end
