defmodule Satie.SpacerTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Spacer}

  describe inspect(&Spacer.new/1) do
    test "returns a rest struct from an assignable duration" do
      assert Spacer.new(Duration.new(3, 8)) == %Spacer{
               written_duration: Duration.new(3, 8)
             }
    end

    test "returns a rest struct from a parseable string" do
      assert Spacer.new("s\\breve") == %Spacer{
               written_duration: Duration.new(2, 1)
             }
    end

    test "returns an error when the duration is not assignable" do
      assert Spacer.new(Duration.new(1, 5)) ==
               {:error, :spacer_new, {:unassignable_duration, 1, 5}}
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a spacer" do
      assert Spacer.new(Duration.new(3, 8)) |> to_string() == "s4."
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a spacer formatted for IEx" do
      assert Spacer.new(Duration.new(7, 8)) |> inspect() == "#Satie.Spacer<s2..>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a spacer" do
      assert Spacer.new(Duration.new(7, 32)) |> Satie.to_lilypond() == "s8.."
      assert Spacer.new(Duration.new(4, 1)) |> Satie.to_lilypond() == "s\\longa"
    end
  end
end
