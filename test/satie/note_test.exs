defmodule Satie.NoteTest do
  use ExUnit.Case

  alias Satie.{Duration, Note, Pitch}
  doctest Note

  @pitch Pitch.new(2, 3)

  describe ".new" do
    test "/2 accepts a pitch and a duration" do
      duration = Duration.new(7,16)
      assert Note.new(@pitch, duration) == %Note{
        written_pitch: %Pitch{
          pitch_class_index: 2,
          octave: 3
        },
        written_duration: %Duration{
          numerator: 7,
          denominator: 16
        }
      }
    end

    test "/2 throws an error if it receives an unassignable duration" do
      assert_raise Satie.UnassignableDurationError, fn ->
        Note.new(@pitch, Duration.new(5, 16))
      end
    end
  end
end
