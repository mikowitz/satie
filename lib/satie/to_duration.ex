defprotocol Satie.ToDuration do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToDuration, for: Any do
  def from(x), do: {:error, :duration_new, x}
end

defimpl Satie.ToDuration, for: Satie.Duration do
  def from(duration), do: duration
end

for fractional <- [Satie.Fraction, Satie.Offset, Satie.Multiplier] do
  defimpl Satie.ToDuration, for: fractional do
    def from(%@for{numerator: n, denominator: d}), do: Satie.Duration.__init__({n, d})
  end
end

defimpl Satie.ToDuration, for: Integer do
  def from(numerator), do: @protocol.from({numerator, 1})
end

defimpl Satie.ToDuration, for: Tuple do
  import Satie.Guards

  def from(duration) when is_integer_duple(duration) do
    Satie.Duration.__init__(duration)
  end

  def from(tuple), do: {:error, :duration_new, tuple}
end

defimpl Satie.ToDuration, for: BitString do
  def from(duration) do
    case Satie.Lilypond.Parser.duration().(duration) do
      {:ok, [base, dots], ""} ->
        dots_count = String.length(dots)
        {n, base} = parse_base_duration(base)

        build_numerator_and_denominator(n, base, dots_count)
        |> Satie.Duration.__init__()

      _ ->
        {:error, :duration_new, duration}
    end
  end

  defp parse_base_duration("\\breve"), do: {2, 1}
  defp parse_base_duration("\\longa"), do: {4, 1}
  defp parse_base_duration("\\maxima"), do: {8, 1}

  defp parse_base_duration(dur) do
    {dur, ""} = Integer.parse(dur)
    {1, dur}
  end

  defp build_numerator_and_denominator(1, base, dots_count) do
    {
      round(:math.pow(2, dots_count + 1) - 1),
      round(:math.pow(2, :math.log2(base) + dots_count))
    }
  end

  defp build_numerator_and_denominator(num, _base, 0) do
    {num, 1}
  end

  defp build_numerator_and_denominator(num, _base, dots_count) do
    {
      round(:math.pow(2, dots_count + 1) - 1),
      round(:math.pow(2, dots_count) / num)
    }
  end
end
