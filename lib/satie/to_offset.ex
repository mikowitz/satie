defprotocol Satie.ToOffset do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToOffset, for: Any do
  def from(x), do: {:error, :offset_new, x}
end

defimpl Satie.ToOffset, for: Satie.Offset do
  def from(offset), do: offset
end

for fractional <- [Satie.Duration, Satie.Multiplier] do
  defimpl Satie.ToOffset, for: fractional do
    def from(%@for{numerator: n, denominator: d}), do: Satie.Offset.__init__({n, d})
  end
end

defimpl Satie.ToOffset, for: Integer do
  def from(numerator), do: Satie.ToOffset.from({numerator, 1})
end

defimpl Satie.ToOffset, for: Tuple do
  import Satie.Guards

  def from(offset) when is_integer_duple(offset) do
    offset
    |> Satie.Offset.__init__()
  end

  def from(tuple), do: {:error, :offset_new, tuple}
end
