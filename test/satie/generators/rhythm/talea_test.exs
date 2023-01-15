defmodule Satie.Generators.Rhythm.TaleaTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.Duration
  alias Satie.Generators.Rhythm.Talea

  describe_function &Talea.new/2 do
    test "takes a set of fractions and a Talea" do
      talea =
        [1, 2, 3, 4]
        |> Enum.map(&Duration.new(&1, 16))
        |> Satie.Talea.new()

      generator = Talea.new([{1, 2}, {5, 8}], talea)

      assert generator.talea == talea
      refute generator.tie_across_boundaries
    end
  end

  describe_function &Satie.ToLilypond.to_lilypond/2 do
    setup do
      measures = [{3, 8}, {4, 8}, {3, 16}, {4, 16}, {5, 8}, {2, 4}]

      {:ok, measures: measures}
    end

    test "a single count repeats a single duration for the entire time", context do
      talea = Satie.Talea.new([Duration.new(1, 16)])

      generator = Talea.new(context.measures, talea)

      expected = File.read!("test/files/talea_rhythm_generator/basic.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "a repeating simple value alternates through all measures", context do
      talea = Satie.Talea.new([Duration.new(1, 16), Duration.new(1, 8)])

      generator = Talea.new(context.measures, talea)

      expected = File.read!("test/files/talea_rhythm_generator/12.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "a more complex talea", context do
      talea =
        4..1
        |> Enum.map(&Duration.new(&1, 16))
        |> Satie.Talea.new()

      generator = Talea.new(context.measures, talea)

      expected = File.read!("test/files/talea_rhythm_generator/4321.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can set extra beats mask", context do
      talea =
        4..1
        |> Enum.map(&Duration.new(&1, 16))
        |> Satie.Talea.new()

      generator =
        Talea.new(context.measures, talea, denominator: 16, extra_beats_per_section: [0, 1, 1])

      expected = File.read!("test/files/talea_rhythm_generator/4321-extra.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "can tie across boundaries", context do
      talea =
        4..1
        |> Enum.map(&Duration.new(&1, 16))
        |> Satie.Talea.new()

      generator =
        Talea.new(context.measures, talea,
          denominator: 16,
          extra_beats_per_section: [0, 1, 1],
          tie_across_boundaries: true
        )

      expected =
        File.read!("test/files/talea_rhythm_generator/4321-extra-tie.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end

    test "negative durations turn into rests", context do
      talea = [4, -3, 2, 1] |> Enum.map(&Duration.new(&1, 16)) |> Satie.Talea.new()

      generator = Talea.new(context.measures, talea, tie_across_boundaries: true)

      expected = File.read!("test/files/talea_rhythm_generator/4321-rests.ly") |> String.trim()

      assert Satie.to_lilypond(generator) == expected
    end
  end
end
