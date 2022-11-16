defmodule Satie.TimeSignature do
  defstruct [:numerator, :denominator]

  use Satie.Attachable, location: :before, priority: 3

  @re ~r/^(\\time\s+)?(?<numerator>\d+)\/(?<denominator>\d+)$/

  def new(time_signature) when is_bitstring(time_signature) do
    case Regex.named_captures(@re, time_signature) do
      %{"numerator" => numerator, "denominator" => denominator} ->
        {n, ""} = Integer.parse(numerator)
        {d, ""} = Integer.parse(denominator)
        new(n, d)

      nil ->
        {:error, :time_signature_new, time_signature}
    end
  end

  def new(numerator, denominator) when is_integer(numerator) and is_integer(denominator) do
    %__MODULE__{
      numerator: numerator,
      denominator: denominator
    }
  end

  def new(numerator, denominator), do: {:error, :time_signature_new, {numerator, denominator}}

  defimpl String.Chars do
    def to_string(%@for{} = time_signature), do: Satie.to_lilypond(time_signature)
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{numerator: n, denominator: d}, _opts) do
      concat([
        "#Satie.TimeSignature<",
        "#{n}/#{d}",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{numerator: n, denominator: d}) do
      "\\time #{n}/#{d}"
    end
  end
end
