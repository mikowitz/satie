defmodule Satie.Generators.Rhythm.Fill do
  @moduledoc """
  Generates a rhythm that fills a set of given durations
  """
  defstruct [:fractions, :tie_across_boundaries, :mask]

  alias Satie.{Duration, Fraction, Measure, Note, Rest, RhythmicStaff, Tie, TimeSignature}

  def new(fractions, options \\ []) when is_list(fractions) do
    with {:ok, fractions} <- validate_fractions(fractions) do
      %__MODULE__{
        fractions: fractions,
        tie_across_boundaries: Keyword.get(options, :tie_across_boundaries, false),
        mask: Keyword.get(options, :mask, [1])
      }
    end
  end

  def generate(%__MODULE__{fractions: fractions, mask: mask, tie_across_boundaries: tie}) do
    mask =
      Stream.cycle(mask) |> Enum.take(length(fractions) + 1) |> Enum.chunk_every(2, 1, :discard)

    fractions
    |> Enum.zip(mask)
    |> Enum.map(&to_filled_measure(&1, tie))
    |> remove_final_tie()
    |> RhythmicStaff.new(name: "Fill Staff")
  end

  defp validate_fractions(fractions) do
    fractions = Enum.map(fractions, &Fraction.new/1)

    case Enum.filter(fractions, &is_tuple/1) do
      [] -> {:ok, fractions}
      bad_fractions -> {:error, :fill_rhythm_generator_new, Enum.map(bad_fractions, &elem(&1, 2))}
    end
  end

  defp to_filled_measure({%Fraction{} = fraction, [1, nxt]}, tie_across_boundaries) do
    ts = TimeSignature.new(fraction)

    notes =
      fraction
      |> Duration.new()
      |> Duration.make_printable_tied_duration()
      |> Enum.map(&Note.new("c", &1))

    notes =
      if tie_across_boundaries && nxt == 1 do
        Enum.map(notes, &Satie.attach(&1, Tie.new()))
      else
        [last | notes] = Enum.reverse(notes)

        notes =
          notes
          |> Enum.map(&Satie.attach(&1, Tie.new()))
          |> Enum.reverse()

        notes ++ [last]
      end

    Measure.new(ts, notes)
  end

  defp to_filled_measure({%Fraction{} = fraction, [0, _]}, _tie_across_boundaries) do
    ts = TimeSignature.new(fraction)

    notes =
      fraction
      |> Duration.new()
      |> Duration.make_printable_tied_duration()
      |> Enum.map(&Rest.new/1)

    Measure.new(ts, notes)
  end

  defp remove_final_tie(measures) do
    measures
    |> update_in([Access.at(-1), -1], fn note ->
      attachments = Enum.reject(note.attachments, &is_struct(&1.attachable, Satie.Tie))

      %{note | attachments: attachments}
    end)
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = fill, options) do
      fill
      |> @for.generate()
      |> @protocol.to_lilypond(options)
    end
  end
end
