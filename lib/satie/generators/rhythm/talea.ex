defmodule Satie.Generators.Rhythm.Talea do
  @moduledoc """
  Models a talea rhythm generator
  """
  defstruct [:fractions, :talea, :tie_across_boundaries, :denominator, :extra_beats_per_section]
  alias Satie.Fraction

  def new(fractions, %Satie.Talea{} = talea, options \\ []) when is_list(fractions) do
    with {:ok, fractions} <- validate_fractions(fractions) do
      %__MODULE__{
        fractions: fractions,
        talea: talea,
        tie_across_boundaries: Keyword.get(options, :tie_across_boundaries, false),
        denominator: Keyword.get(options, :denominator, 8),
        extra_beats_per_section: Keyword.get(options, :extra_beats_per_section, [0])
      }
    end
  end

  alias Satie.{
    Duration,
    Fractional,
    Measure,
    Multiplier,
    Note,
    Rest,
    RhythmicStaff,
    Tie,
    TimeSignature,
    Tuplet
  }

  def generate(%__MODULE__{
        fractions: fractions,
        talea: talea,
        extra_beats_per_section: extras,
        tie_across_boundaries: tie,
        denominator: denom
      }) do
    fractions
    |> Enum.zip(Stream.cycle(extras))
    |> Enum.reduce({0, [], []}, fn {fraction, extra}, {talea_index, next_measure, measures} ->
      full_fraction = Fraction.add(fraction, Fraction.new(extra, denom))

      {new_talea_index, spillover, filled_measure} =
        fill_measure(full_fraction, extra, denom, next_measure, talea, talea_index)

      {new_talea_index, spillover, [filled_measure | measures]}
    end)
    |> elem(2)
    |> Enum.reverse()
    |> then(&Enum.zip([fractions, &1, Stream.cycle(extras)]))
    |> Enum.map(&construct_measure(&1, denom, tie))
    |> clear_ties_to_rests()
    |> RhythmicStaff.new(name: "Talea Staff")
    |> remove_final_tie()
  end

  defp clear_ties_to_rests(measures) do
    measures
    |> Enum.chunk_every(2, 1)
    |> Enum.map(fn
      [m1, m2] ->
        case starts_with_rest?(m2) do
          true -> remove_final_tie(m1)
          false -> m1
        end

      [m1] ->
        m1
    end)
  end

  defp starts_with_rest?(%Rest{}), do: true
  defp starts_with_rest?(%{contents: [head | _]}), do: starts_with_rest?(head)
  defp starts_with_rest?(_), do: false

  defp construct_measure({fraction, durations, extras}, denom, tie) do
    notes =
      Enum.map(durations, fn
        %Duration{} = duration ->
          note_or_rest_from_duration(duration)

        {%Duration{} = duration, :tie} ->
          case note_or_rest_from_duration(duration) do
            %Note{} = note -> Satie.attach(note, Tie.new())
            %Rest{} = rest -> rest
          end
      end)

    notes =
      case tie do
        false -> notes
        true -> update_in(notes, [Access.at(-1)], &attach_tie_if_not_tied/1)
      end

    build_measure(fraction, notes, extras, denom)
  end

  defp note_or_rest_from_duration(duration) do
    case Duration.negative?(duration) do
      true -> Rest.new(Duration.negate(duration))
      false -> Note.new("c", duration)
    end
  end

  defp attach_tie_if_not_tied(%Note{attachments: attachments} = note) do
    case Enum.any?(attachments, &is_struct(&1.attachable, Satie.Tie)) do
      true -> note
      false -> Satie.attach(note, Tie.new())
    end
  end

  defp attach_tie_if_not_tied(%Rest{} = rest), do: rest

  defp build_measure(fraction, notes, 0, _denom) do
    time_signature = TimeSignature.new(fraction)
    Measure.new(time_signature, notes)
  end

  defp build_measure(fraction, notes, extras, denom) do
    {n, d} = Fraction.divide(fraction, Fraction.new(extras, denom)) |> Fractional.to_tuple()
    original_count = div(n, d)

    Measure.new(
      TimeSignature.new(fraction),
      [
        Tuplet.new(Multiplier.new(original_count, original_count + extras), notes)
      ]
    )
  end

  defp fill_measure(fraction, extra, denom, current_measure, talea, talea_index) do
    total_duration = Duration.new(fraction)
    next_duration = Satie.Talea.at(talea, talea_index)

    current_filled =
      current_measure
      |> Enum.map(&Duration.abs/1)
      |> Duration.sum()

    remaining = Duration.subtract(total_duration, current_filled)

    cond do
      Duration.lt(Duration.abs(next_duration), remaining) ->
        fill_measure(
          fraction,
          extra,
          denom,
          [next_duration | current_measure],
          talea,
          talea_index + 1
        )

      Duration.eq(Duration.abs(next_duration), remaining) ->
        {talea_index + 1, [], Enum.reverse([next_duration | current_measure])}

      Duration.gt(Duration.abs(next_duration), remaining) ->
        spillover = Duration.subtract(Duration.abs(next_duration), remaining)

        {remaining, spillover} =
          case Duration.negative?(next_duration) do
            true -> {Duration.negate(remaining), Duration.negate(spillover)}
            false -> {{remaining, :tie}, spillover}
          end

        {talea_index + 1, [spillover], Enum.reverse([remaining | current_measure])}
    end
  end

  defp remove_final_tie(staff) do
    update_in(staff, [Satie.leaf(-1)], &remove_tie/1)
  end

  defp remove_tie(%{attachments: attachments} = leaf) do
    attachments = Enum.reject(attachments, &is_struct(&1.attachable, Satie.Tie))
    %{leaf | attachments: attachments}
  end

  defp validate_fractions(fractions) do
    fractions = Enum.map(fractions, &Fraction.new/1)

    case Enum.filter(fractions, &is_tuple/1) do
      [] -> {:ok, fractions}
      bad_fractions -> {:error, :fill_rhythm_generator_new, Enum.map(bad_fractions, &elem(&1, 2))}
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = talea, options) do
      talea
      |> @for.generate()
      |> @protocol.to_lilypond(options)
    end
  end
end
