defprotocol Satie.ToFraction do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToFraction, for: Any do
  def from(x), do: {:error, :fraction_new, x}
end

defimpl Satie.ToFraction, for: Satie.Fraction do
  def from(fraction), do: fraction
end

for fractional <- [Satie.Duration, Satie.Multiplier, Satie.Offset] do
  defimpl Satie.ToFraction, for: fractional do
    def from(%@for{numerator: n, denominator: d}), do: Satie.Fraction.__init__({n, d})
  end
end

defimpl Satie.ToFraction, for: BitString do
  def from(fraction) do
    case Satie.Lilypond.Parser.fraction().(fraction) do
      {:ok, [n, d], ""} ->
        @protocol.from({n, d})

      _ ->
        {:error, :fraction_new, fraction}
    end
  end
end

defimpl Satie.ToFraction, for: Integer do
  def from(numerator), do: @protocol.from({numerator, 1})
end

defimpl Satie.ToFraction, for: Tuple do
  import Satie.Guards

  def from(fraction) when is_integer_duple(fraction) do
    fraction
    |> Satie.Fraction.__init__()
  end

  def from(tuple), do: {:error, :fraction_new, tuple}
end
