defmodule Satie.ArticulationTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Articulation, Note}

  doctest Articulation

  describe_function &Articulation.new/1 do
    test "creates an articulation with the correct name" do
      assert Articulation.new("accent") == %Articulation{
               name: "accent",
               components: [
                 after: [
                   "\\accent"
                 ]
               ]
             }
    end
  end

  describe "attaching an articulation to a note" do
    test "with default position" do
      note = Note.new("c'4")

      accent = Articulation.new("accent")
      marcato = Articulation.new("marcato")
      mordent = Articulation.new("mordent")

      note = Satie.attach(note, accent)
      note = Satie.attach(note, marcato, direction: :down)
      note = Satie.attach(note, mordent, priority: -1, direction: :up)

      assert Satie.to_lilypond(note) ==
               """
               c'4
                 ^ \\mordent
                 - \\accent
                 _ \\marcato
               """
               |> String.trim()
    end
  end
end
