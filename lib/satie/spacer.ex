defmodule Satie.Spacer do
  @moduledoc """
  Models an unprinted spacer rest
  """
  use Satie.Leaf

  alias Satie.Duration

  def new(%Duration{numerator: n, denominator: d} = duration) do
    case Duration.printable?(duration) do
      true -> %__MODULE__{written_duration: duration}
      false -> {:error, :spacer_new, {:unassignable_duration, n, d}}
    end
  end

  @re ~r/^s(?<duration>(\\breve|\\longa|\\maxima|\d+)\.*)$/

  def new(spacer) when is_bitstring(spacer) do
    case Regex.named_captures(@re, spacer) do
      %{"duration" => duration} -> new(Duration.new(duration))
      nil -> {:error, :spacer_new, spacer}
    end
  end

  defimpl String.Chars do
    def to_string(%@for{} = spacer) do
      Satie.to_lilypond(spacer)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = spacer, _opts) do
      concat([
        "#Satie.Spacer<",
        Satie.to_lilypond(spacer),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{written_duration: duration} = spacer, _opts) do
      {attachments_before, attachments_after} = attachments_to_lilypond(spacer)

      [
        attachments_before,
        "s" <> Satie.to_lilypond(duration),
        attachments_after
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end
  end
end
