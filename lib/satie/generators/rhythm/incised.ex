defmodule Satie.Generators.Rhythm.Incised do
  @moduledoc """
    Defines an incised rhythm generator
  """

  use Satie.Generator

  alias Satie.{
    Duration,
    Fraction,
    Fractional,
    Generators.Rhythm.IncisionRule,
    Measure,
    Multiplier,
    Note,
    Rest,
    RhythmicStaff,
    TimeSignature,
    Tuplet
  }

  defstruct [
    :fractions,
    :tie_across_boundaries,
    :extra_beats_per_section,
    :denominator,
    :incision_rule,
    :fill_with_rests,
    __generator__: true
  ]

  def new(fractions, %IncisionRule{} = incision_rule \\ %IncisionRule{}, options \\ [])
      when is_list(fractions) do
    with {:ok, fractions} <- validate_fractions(fractions) do
      %__MODULE__{
        fractions: fractions,
        incision_rule: incision_rule,
        fill_with_rests: Keyword.get(options, :fill_with_rests, false),
        tie_across_boundaries: Keyword.get(options, :tie_across_boundaries, false),
        extra_beats_per_section: Keyword.get(options, :extra_beats_per_section, [0]),
        denominator: Keyword.get(options, :denominator, 8)
      }
    end
  end

  def generate(%__MODULE__{fractions: fractions} = generator) do
    {:ok, pid} =
      Agent.start(fn ->
        %{
          prefix: %{talea: 0, counts: 0},
          suffix: %{talea: 0, counts: 0}
        }
      end)

    {^pid, measures} =
      fractions
      |> Enum.with_index()
      |> Enum.zip(Stream.cycle(generator.extra_beats_per_section))
      |> Enum.reduce({pid, []}, fn {{fraction, index}, extras}, {talea_counts_agent, measures} ->
        {agent, measure} =
          build_measure(
            fraction,
            {index, length(fractions) - 1},
            {extras, generator.denominator, generator.fill_with_rests},
            talea_counts_agent,
            generator.incision_rule,
            generator.tie_across_boundaries
          )

        {agent, [measure | measures]}
      end)

    Agent.stop(pid)

    measures
    |> Enum.reverse()
    |> RhythmicStaff.new(name: "Incised Staff")
    |> remove_final_tie()
  end

  defp build_measure(
         fraction,
         {index, final_index},
         {extras, denom, fill_with_rests},
         talea_counts_agent,
         %{outer_divisions_only: outer_only} = incision_rule,
         tie
       ) do
    should_apply_prefix_incision = !outer_only || (outer_only and index == 0)
    should_apply_suffix_incision = !outer_only || (outer_only and index == final_index)

    should_apply_incision = should_apply_prefix_incision || should_apply_suffix_incision

    if should_apply_incision do
      full_fraction = Fraction.add(fraction, Fraction.new(extras, denom))

      {new_suffix_counts_index, new_suffix_talea_index, suffixes} =
        get_incisions(should_apply_suffix_incision, talea_counts_agent, :suffix, incision_rule)

      {new_prefix_counts_index, new_prefix_talea_index, prefixes} =
        get_incisions(should_apply_prefix_incision, talea_counts_agent, :prefix, incision_rule)

      total_incision =
        (prefixes ++ suffixes)
        |> Enum.map(& &1.written_duration)
        |> Enum.map(&Duration.abs/1)
        |> Duration.sum()

      total_duration = Duration.new(full_fraction)

      incised_duration = Duration.subtract(total_duration, total_incision)

      main = build_unincised_portion(incised_duration, fill_with_rests)

      notes = prefixes ++ main ++ suffixes

      notes =
        notes
        |> clamp(Duration.new(full_fraction))
        |> maybe_add_final_tie(tie)

      measure = construct_measure_struct(fraction, notes, extras, denom)

      Agent.update(talea_counts_agent, fn _ ->
        %{
          prefix: %{
            talea: new_prefix_talea_index,
            counts: new_prefix_counts_index
          },
          suffix: %{
            talea: new_suffix_talea_index,
            counts: new_suffix_counts_index
          }
        }
      end)

      {talea_counts_agent, measure}
    else
      build_unincised_measure(fraction, tie, fill_with_rests, talea_counts_agent)
    end
  end

  defp build_incisions(talea, counts, talea_index, counts_index) do
    count = Satie.Talea.at(counts, counts_index)

    incisions =
      case count do
        0 -> []
        count -> Enum.map(0..(count - 1), &Satie.Talea.at(talea, &1 + talea_index))
      end

    new_counts_index = counts_index + 1
    new_talea_index = talea_index + count

    incisions =
      Enum.map(incisions, fn incision ->
        durations = incision |> Duration.abs() |> Duration.make_printable_tied_duration()

        case Duration.negative?(incision) do
          true ->
            Enum.map(durations, &Rest.new/1)

          false ->
            durations
            |> Enum.map(&Note.new("c", &1))
            |> tie_chain()
        end
      end)
      |> List.flatten()

    {new_counts_index, new_talea_index, incisions}
  end

  defp get_incisions(should_apply, talea_counts_agent, name, incision_rule) do
    %{counts: counts_index, talea: talea_index} = Agent.get(talea_counts_agent, & &1[name])

    case should_apply do
      false ->
        {counts_index, talea_index, []}

      true ->
        talea = IncisionRule.talea(incision_rule, name)
        counts = Satie.Talea.new(Map.get(incision_rule, :"#{name}_counts"))
        build_incisions(talea, counts, talea_index, counts_index)
    end
  end

  defp build_unincised_portion(duration, fill_with_rests) do
    duration
    |> Duration.make_printable_tied_duration()
    |> durations_to_notes_or_rests(fill_with_rests)
  end

  defp durations_to_notes_or_rests(durations, fill_with_rests) do
    durations
    |> Enum.map(&duration_to_note_or_rest(&1, fill_with_rests))
    |> tie_chain()
  end

  defp duration_to_note_or_rest(duration, true), do: Rest.new(duration)
  defp duration_to_note_or_rest(duration, false), do: Note.new("c", duration)

  defp construct_measure_struct(fraction, notes, extras, denominator) do
    case extras do
      0 ->
        Measure.new(TimeSignature.new(fraction), notes)

      extras ->
        build_tupleted_measure(fraction, notes, extras, denominator)
    end
  end

  defp build_tupleted_measure(fraction, notes, extras, denominator) do
    {n, d} = Fraction.divide(fraction, Fraction.new(extras, denominator)) |> Fractional.to_tuple()

    original_count = div(n, d)

    Measure.new(
      TimeSignature.new(fraction),
      [
        Tuplet.new(Multiplier.new(original_count, original_count + extras), notes)
      ]
    )
  end

  defp build_unincised_measure(fraction, tie, fill_with_rests, talea_counts_agent) do
    notes =
      fraction
      |> Duration.new()
      |> build_unincised_portion(fill_with_rests)
      |> maybe_add_final_tie(tie)

    {talea_counts_agent, Measure.new(TimeSignature.new(fraction), notes)}
  end

  defp maybe_add_final_tie(notes, tie) do
    case tie do
      false -> notes
      true -> update_in(notes, [Access.at(-1)], &attach_tie_if_not_tied/1)
    end
  end

  defp clamp(notes, total) do
    if Duration.lte(Duration.sum(Enum.map(notes, & &1.written_duration)), total) do
      notes
    else
      Enum.reduce_while(notes, [], fn note, acc ->
        remaining =
          Duration.subtract(
            Duration.new(total),
            Duration.sum(Enum.map(acc, & &1.written_duration))
          )

        cond do
          Duration.lt(note.written_duration, remaining) ->
            {:cont, [note | acc]}

          Duration.eq(note.written_duration, remaining) ->
            {:halt, [note | acc]}

          true ->
            clamped_note = %{note | written_duration: Duration.new(remaining)}
            {:halt, [clamped_note | acc]}
        end
      end)
      |> Enum.reverse()
    end
  end
end
