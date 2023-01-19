defmodule Satie.Generators.Rhythm.EvenTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.Generators.Rhythm.Even

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    setup do
      measures = [{3, 8}, {4, 8}, {3, 16}, {4, 16}, {5, 8}, {2, 4}]

      {:ok, measures: measures}
    end

    test "returns the correct lilypond output for a simple generator", context do
      generator = Even.new(context.measures)

      expected = File.read!("test/files/even_rhythm_generator/basic.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can cycle denominators", context do
      generator = Even.new(context.measures, denominators: [8, 16])

      expected =
        File.read!("test/files/even_rhythm_generator/cyclic-denominators.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "will tupletize for denominators that don't fill perfectly", context do
      generator = Even.new(context.measures, denominators: [8, 4, 16])

      expected =
        File.read!("test/files/even_rhythm_generator/tuplet-denominators.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can add extra counts per measure", context do
      generator = Even.new(context.measures, denominators: [8], extra_beats_per_section: [0, 1])

      expected = File.read!("test/files/even_rhythm_generator/extra-beats.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can tie across boundaries", context do
      generator =
        Even.new(context.measures,
          denominators: [8],
          extra_beats_per_section: [0, 1],
          tie_across_boundaries: true
        )

      expected =
        File.read!("test/files/even_rhythm_generator/extra-beats-tied.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end
  end
end
