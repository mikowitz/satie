defmodule Satie.ArticulationTest do
  use ExUnit.Case, async: true

  alias Satie.Articulation

  describe "new/1" do
    test "defaults position to neutral" do
      assert Articulation.new("accent") == %Articulation{
               name: "accent",
               position: :neutral
             }
    end
  end

  describe "new/2" do
    test "can set the articulation position" do
      assert Articulation.new("staccato", :up) == %Articulation{
               name: "staccato",
               position: :up
             }

      assert Articulation.new("marcato", :down) == %Articulation{
               name: "marcato",
               position: :down
             }
    end

    test "position defaults to neutral if the value passed is invalid" do
      assert Articulation.new("marcato", :whatever) == %Articulation{
               name: "marcato",
               position: :neutral
             }
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of an articulation" do
      assert Articulation.new("staccato") |> to_string() == "- \\staccato"

      assert Articulation.new("marcato", :up) |> to_string() == "^ \\marcato"

      assert Articulation.new("accent", :down) |> to_string() == "_ \\accent"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns an articulation formatted for IEx" do
      assert Articulation.new("staccato") |> inspect() == "#Satie.Articulation<- \\staccato>"

      assert Articulation.new("marcato", :up) |> inspect() == "#Satie.Articulation<^ \\marcato>"

      assert Articulation.new("accent", :down) |> inspect() == "#Satie.Articulation<_ \\accent>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of an articulation" do
      assert Articulation.new("staccato") |> Satie.to_lilypond() == "- \\staccato"

      assert Articulation.new("marcato", :up) |> Satie.to_lilypond() == "^ \\marcato"

      assert Articulation.new("accent", :down) |> Satie.to_lilypond() == "_ \\accent"
    end
  end
end
