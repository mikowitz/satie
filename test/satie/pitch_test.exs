defmodule Satie.PitchTest do
  use ExUnit.Case

  alias Satie.Pitch
  doctest Pitch

  describe ".new" do
    test "/0 returns middle C" do
      assert Pitch.new() == %Pitch{
        pitch_class_index: 0,
        octave: 4
      }
    end

    test "/1 returns a pitch in the octave above middle C" do
      assert Pitch.new(3) == %Pitch{
        pitch_class_index: 3,
        octave: 4
      }
    end

    test "/2 converts pitch class indices into modulo 12" do
      assert Pitch.new(12, 3) == %Pitch{
        pitch_class_index: 0,
        octave: 3
      }

      assert Pitch.new(19, 4) == %Pitch{
        pitch_class_index: 7,
        octave: 4
      }

      assert Pitch.new(-3, 2) == %Pitch{
        pitch_class_index: 9,
        octave: 2
      }
    end
  end
end
