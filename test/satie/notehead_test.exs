defmodule Satie.NoteheadTest do
  use ExUnit.Case, async: true

  alias Satie.{Interval, Notehead, Pitch}

  describe inspect(&Notehead.new/1) do
    test "returns a notehead from a pitch" do
      pitch = Pitch.new("c+'")

      assert Notehead.new(pitch) == %Notehead{
               written_pitch: pitch,
               accidental_display: :neutral
             }
    end

    test "can initialize from a string" do
      assert Notehead.new("ftqs") == %Notehead{
               written_pitch: Pitch.new("ftqs"),
               accidental_display: :neutral
             }

      assert Notehead.new("af?") == %Notehead{
               written_pitch: Pitch.new("af"),
               accidental_display: :cautionary
             }

      assert Notehead.new("g!") == %Notehead{
               written_pitch: Pitch.new("g"),
               accidental_display: :forced
             }
    end
  end

  describe inspect(&Notehead.new/2) do
    test "can specify the accidental display type" do
      pitch = Pitch.new("c+'")

      assert Notehead.new(pitch, accidental_display: :forced) == %Notehead{
               written_pitch: pitch,
               accidental_display: :forced
             }

      assert Notehead.new(pitch, accidental_display: :cautionary) == %Notehead{
               written_pitch: pitch,
               accidental_display: :cautionary
             }
    end

    test "sets `:default` if any other value is passed for the accidental display" do
      pitch = Pitch.new("c+'")

      assert Notehead.new(pitch, accidental_display: "anything else") == %Notehead{
               written_pitch: pitch,
               accidental_display: :neutral
             }
    end
  end

  describe inspect(&Notehead.transpose/2) do
    test "returns a notehead transposed by the given interval" do
      notehead = Notehead.new("c'")

      assert Notehead.transpose(notehead, Interval.new("+m3")) ==
               Notehead.new("ef'")

      assert Notehead.transpose(notehead, Interval.new("-P5")) ==
               Notehead.new("f")
    end
  end

  describe inspect(&Notehead.invert/2) do
    test "returns a notehead inverted around the given axis" do
      notehead = Notehead.new("c'")

      assert Notehead.invert(notehead, Pitch.new("f'")) ==
               Notehead.new("bf'")

      assert Notehead.invert(notehead, Pitch.new("bf'")) ==
               Notehead.new("af''")

      assert Notehead.invert(notehead, Pitch.new("a")) ==
               Notehead.new("fs")
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a string representation of a notehead" do
      pitch = Pitch.new("c+")
      assert Notehead.new(pitch) |> to_string() == "cqs"
      assert Notehead.new(pitch, accidental_display: :cautionary) |> to_string() == "cqs?"
      assert Notehead.new(pitch, accidental_display: :forced) |> to_string() == "cqs!"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a notehead formatted for IEx" do
      pitch = Pitch.new("c+")
      assert Notehead.new(pitch) |> inspect() == "#Satie.Notehead<cqs>"

      assert Notehead.new(pitch, accidental_display: :cautionary) |> inspect() ==
               "#Satie.Notehead<cqs?>"

      assert Notehead.new(pitch, accidental_display: :forced) |> inspect() ==
               "#Satie.Notehead<cqs!>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns the correct lilypond representation of a notehead" do
      pitch = Pitch.new("c+")
      assert Notehead.new(pitch) |> Satie.to_lilypond() == "cqs"
      assert Notehead.new(pitch, accidental_display: :cautionary) |> Satie.to_lilypond() == "cqs?"
      assert Notehead.new(pitch, accidental_display: :forced) |> Satie.to_lilypond() == "cqs!"
    end
  end
end
