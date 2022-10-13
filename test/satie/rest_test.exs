defmodule Satie.RestTest do
  use ExUnit.Case, async: true

  alias Satie.{Duration, Rest}

  describe inspect(&Rest.new/1) do
    test "returns a rest struct from an assignable duration" do
      assert Rest.new(Duration.new(1, 4)) == %Rest{
               written_duration: Duration.new(1, 4)
             }
    end

    test "returns a rest struct from a parseable string" do
      assert Rest.new("r8.") == %Rest{
               written_duration: Duration.new(3, 16)
             }
    end

    test "returns an error when the duration is not assignable" do
      assert Rest.new(Duration.new(1, 5)) == {:error, :rest_new, {:unassignable_duration, 1, 5}}
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a rest" do
      assert Rest.new(Duration.new(3, 8)) |> to_string() == "r4."
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a rest formatted for IEx" do
      assert Rest.new(Duration.new(7, 8)) |> inspect() == "#Satie.Rest<r2..>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a rest" do
      assert Rest.new(Duration.new(3, 8)) |> Satie.to_lilypond() == "r4."
      assert Rest.new(Duration.new(3, 1)) |> Satie.to_lilypond() == "r\\breve."
    end
  end
end
