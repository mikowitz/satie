defprotocol Satie.ToMultiplier do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToMultiplier, for: Any do
  def from(x), do: {:error, :multiplier_new, x}
end

defimpl Satie.ToMultiplier, for: Satie.Multiplier do
  def from(multiplier), do: multiplier
end

for fractional <- [Satie.Duration, Satie.Fraction, Satie.Offset] do
  defimpl Satie.ToMultiplier, for: fractional do
    def from(%@for{numerator: n, denominator: d}), do: Satie.Multiplier.__init__({n, d})
  end
end

defimpl Satie.ToMultiplier, for: BitString do
  def from(multiplier) do
    case Satie.Lilypond.Parser.fraction().(multiplier) do
      {:ok, [n, d], ""} ->
        @protocol.from({n, d})

      _ ->
        {:error, :multiplier_new, multiplier}
    end
  end
end

defimpl Satie.ToMultiplier, for: Integer do
  def from(numerator), do: Satie.ToMultiplier.from({numerator, 1})
end

defimpl Satie.ToMultiplier, for: Tuple do
  import Satie.Guards

  def from(multiplier) when is_integer_duple(multiplier) do
    Satie.Multiplier.__init__(multiplier)
  end

  def from(tuple), do: {:error, :multiplier_new, tuple}
end
