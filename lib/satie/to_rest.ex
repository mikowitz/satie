defprotocol Satie.ToRest do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToRest, for: Any do
  def from(x), do: {:error, :rest_new, x}
end

defimpl Satie.ToRest, for: Satie.Rest do
  def from(rest), do: rest
end

for leaf <- [Satie.Chord, Satie.Note, Satie.Spacer] do
  defimpl Satie.ToRest, for: leaf do
    def from(%{written_duration: duration}) do
      @protocol.from(duration)
    end
  end
end

defimpl Satie.ToRest, for: Satie.Duration do
  def from(duration) do
    case Satie.Duration.printable?(duration) do
      true ->
        %Satie.Rest{
          written_duration: duration
        }

      false ->
        {:error, :rest_new, {:unassignable_duration, duration}}
    end
  end
end

defimpl Satie.ToRest, for: BitString do
  @rest_re ~r/^r?(?<duration>(\\breve|\\longa|\\maxima|\d+)\.*)$/

  def from(rest) do
    case Regex.named_captures(@rest_re, rest) do
      %{"duration" => duration} -> @protocol.from(Satie.Duration.new(duration))
      nil -> {:error, :rest_new, rest}
    end
  end
end

defimpl Satie.ToRest, for: Tuple do
  import Satie.Guards

  def from(duration) when is_integer_duple(duration) do
    Satie.Duration.new(duration)
    |> @protocol.from()
  end
end

defimpl Satie.ToRest, for: Integer do
  def from(numerator), do: @protocol.from({numerator, 1})
end
