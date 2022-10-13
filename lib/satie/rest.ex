defmodule Satie.Rest do
  defstruct [:written_duration]

  alias Satie.Duration

  def new(%Duration{numerator: n, denominator: d} = duration) do
    case Duration.printable?(duration) do
      true -> %__MODULE__{written_duration: duration}
      false -> {:error, :rest_new, {:unassignable_duration, n, d}}
    end
  end

  @rest_re ~r/^r(?<duration>(\\breve|\\longa|\\maxima|\d+)\.*)$/

  def new(rest) when is_bitstring(rest) do
    case Regex.named_captures(@rest_re, rest) do
      %{"duration" => duration} -> new(Duration.new(duration))
      nil -> {:error, :rest_new, rest}
    end
  end

  defimpl String.Chars do
    def to_string(%@for{} = rest) do
      Satie.to_lilypond(rest)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = rest, _opts) do
      concat([
        "#Satie.Rest<",
        Satie.to_lilypond(rest),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{written_duration: duration}) do
      "r" <> Satie.to_lilypond(duration)
    end
  end
end
