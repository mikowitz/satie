defmodule Satie.MeasureTest do
  use ExUnit.Case, async: true

  alias Satie.{Measure, Note, TimeSignature}

  describe inspect(&Measure.new/2) do
    test "sets a time signature and contents" do
      measure =
        Measure.new(
          TimeSignature.new(3, 4),
          [Note.new("c'4")]
        )

      assert measure.time_signature == %TimeSignature{
               numerator: 3,
               denominator: 4,
               components: [
                 before: ["\\time 3/4"]
               ]
             }

      assert length(measure.contents) == 1
    end

    test "returns an error if passed bad contents" do
      assert Measure.new(TimeSignature.new(3, 4), [2, :Note]) ==
               {:error, :measure_new, [2, :Note]}
    end

    test "can be initialized with a time signature tuple" do
      assert Measure.new({4, 4}) == %Measure{
               time_signature: %TimeSignature{
                 numerator: 4,
                 denominator: 4,
                 components: [
                   before: ["\\time 4/4"]
                 ]
               },
               contents: []
             }
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a simple string output of the measure" do
      measure = Measure.new({3, 4}, [Note.new("c'4"), Note.new("ef'4")])

      assert to_string(measure) == "{ 3/4 c'4 ef'4 }"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a measure formatted for IEx" do
      measure = Measure.new({3, 4}, [Note.new("c'4"), Note.new("ef'4")])

      assert inspect(measure) == "#Satie.Measure<{ 3/4 c'4 ef'4 }>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns valid Lilypond output for a measure" do
      measure = Measure.new({3, 4}, [Note.new("c'4"), Note.new("ef'4"), Note.new("f'4")])

      assert Satie.to_lilypond(measure) ==
               """
               {
                 \\time 3/4
                 c'4
                 ef'4
                 f'4
                 |
               }
               """
               |> String.trim()
    end
  end
end
