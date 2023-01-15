defmodule Satie.Generators.Rhythm.Fill do
  @moduledoc """
  Generates a rhythm that fills a set of given durations
  """
  defstruct [:fractions, :tie_across_boundaries, :mask, __generator__: true]

  alias Satie.{Duration, Fraction, Measure, Note, Rest, RhythmicStaff, Tie, TimeSignature}
  use Satie.Generator

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
    mask = Stream.cycle(mask) |> Stream.chunk_every(2, 1)

    fractions
    |> Enum.zip(mask)
    |> Enum.map(&to_filled_measure(&1, tie))
    |> RhythmicStaff.new(name: "Fill Staff")
    |> remove_final_tie()
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
        tie_chain(notes)
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
end
