defmodule Satie.Generators.Rhythm.Even do
  @moduledoc """
    Generates a sequence where each section is filled with even sub divisions
  """

  # TODO:
  # cyclic masking and/or burnishing

  use Satie.Generator

  defstruct [
    :fractions,
    :tie_across_boundaries,
    :extra_beats_per_section,
    :denominators,
    __generator__: true
  ]

  alias Satie.{Duration, Fraction, Measure, Note, RhythmicStaff, TimeSignature, Tuplet}

  def new(fractions, options \\ []) do
    %__MODULE__{
      fractions: fractions,
      tie_across_boundaries: Keyword.get(options, :tie_across_boundaries, false),
      extra_beats_per_section: Keyword.get(options, :extra_beats_per_section, [0]),
      denominators: Keyword.get(options, :denominators, [8])
    }
  end

  def generate(%__MODULE__{fractions: fractions, denominators: denominators} = generator) do
    fractions
    |> Enum.map(&Fraction.new/1)
    |> then(
      &Enum.zip([&1, Stream.cycle(denominators), Stream.cycle(generator.extra_beats_per_section)])
    )
    |> Enum.map(&build_measure(&1, generator.tie_across_boundaries))
    |> RhythmicStaff.new(name: "Even Staff")
  end

  defp build_measure({fraction, denominator, extra}, tie) do
    duration = Duration.new(fraction)
    division = Duration.new(1, denominator)

    full_duration = Fraction.add(fraction, Fraction.new(extra, denominator)) |> Duration.new()

    division_count = Duration.divide(full_duration, division)

    {notes, multiplier} =
      case {division_count, extra} do
        {%{numerator: n, denominator: 1}, 0} ->
          {Stream.cycle([division]) |> Enum.take(n), nil}

        {%{numerator: n, denominator: 1}, 1} ->
          {Stream.cycle([division]) |> Enum.take(n), Duration.divide(duration, full_duration)}

        {%{numerator: n, denominator: d}, 0} ->
          if n / d < 2 do
            {[duration], nil}
          else
            printed_count = div(n, d)
            durations = Stream.cycle([division]) |> Enum.take(printed_count)
            printed_duration = Duration.sum(durations)
            mult = Duration.divide(duration, printed_duration)
            {durations, mult}
          end
      end

    notes =
      notes
      |> Enum.map(&Note.new("c", &1))

    contents =
      case multiplier do
        nil -> notes
        multiplier -> [Tuplet.new(multiplier, notes)]
      end

    measure = Measure.new(TimeSignature.new(fraction), contents)

    case tie do
      false -> measure
      true -> update_in(measure, [Satie.leaf(-1)], &attach_tie_if_not_tied/1)
    end
  end
end
