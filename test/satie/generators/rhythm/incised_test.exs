defmodule Satie.Generators.Rhythm.IncisedTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.Generators.Rhythm.{Incised, IncisionRule}

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    setup do
      measures = [{3, 8}, {4, 8}, {3, 16}, {4, 16}, {5, 8}, {2, 4}]

      {:ok, measures: measures}
    end

    test "with a default incision rule, returns equivalent to a simple fill generator", context do
      generator = Incised.new(context.measures)

      expected = File.read!("test/files/incised_rhythm_generator/basic.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can set a static suffix incision", context do
      incision_rule = %IncisionRule{
        suffix_counts: [1],
        suffix_talea: [-1],
        suffix_denominator: 16
      }

      generator = Incised.new(context.measures, incision_rule)

      expected = File.read!("test/files/incised_rhythm_generator/suffix.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can set a suffix talea incision", context do
      incision_rule = %IncisionRule{
        suffix_counts: [1],
        suffix_talea: [-1, -2, -3],
        suffix_denominator: 16
      }

      generator = Incised.new(context.measures, incision_rule)

      expected =
        File.read!("test/files/incised_rhythm_generator/suffix-talea.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can set a prefix talea incision", context do
      incision_rule = %IncisionRule{
        prefix_counts: [2, 1],
        prefix_talea: [2, 1],
        prefix_denominator: 16
      }

      generator = Incised.new(context.measures, incision_rule)

      expected =
        File.read!("test/files/incised_rhythm_generator/prefix-talea.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can set incision on both sides", context do
      incision_rule = %IncisionRule{
        prefix_counts: [2, 1],
        prefix_talea: [1, 2],
        prefix_denominator: 16,
        suffix_counts: [1],
        suffix_talea: [-1, -2, -3],
        suffix_denominator: 16
      }

      generator = Incised.new(context.measures, incision_rule)

      expected = File.read!("test/files/incised_rhythm_generator/both-talea.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can tie across boundaries", context do
      incision_rule = %IncisionRule{
        prefix_counts: [2, 1],
        prefix_talea: [1, 2],
        prefix_denominator: 16,
        suffix_counts: [1],
        suffix_talea: [1, 2, 3],
        suffix_denominator: 16
      }

      generator = Incised.new(context.measures, incision_rule, tie_across_boundaries: true)

      expected = File.read!("test/files/incised_rhythm_generator/tied.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can add extra beats to measures", context do
      incision_rule = %IncisionRule{
        prefix_counts: [2, 1],
        prefix_talea: [1, 2],
        prefix_denominator: 16,
        suffix_counts: [1],
        suffix_talea: [1, 2, 3],
        suffix_denominator: 16
      }

      generator =
        Incised.new(context.measures, incision_rule,
          extra_beats_per_section: [0, 1],
          denominator: 16
        )

      expected = File.read!("test/files/incised_rhythm_generator/extra-beats.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can limit to the first and last divisions", context do
      incision_rule = %IncisionRule{
        prefix_counts: [2, 1],
        prefix_talea: [1, -2],
        prefix_denominator: 16,
        suffix_counts: [1],
        suffix_talea: [-1, -2, -3],
        suffix_denominator: 16,
        outer_divisions_only: true
      }

      generator =
        Incised.new(context.measures, incision_rule,
          extra_beats_per_section: [1, 0],
          denominator: 16,
          tie_across_boundaries: true
        )

      expected = File.read!("test/files/incised_rhythm_generator/outer-only.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can set the generator to fill unincised sections with rests", context do
      incision_rule = %IncisionRule{
        prefix_counts: [2, 1],
        prefix_talea: [1, 2],
        prefix_denominator: 16,
        suffix_counts: [1],
        suffix_talea: [1, 2, 3],
        suffix_denominator: 16
      }

      generator = Incised.new(context.measures, incision_rule, fill_with_rests: true)

      expected =
        File.read!("test/files/incised_rhythm_generator/fill-with-rests.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end
  end
end
