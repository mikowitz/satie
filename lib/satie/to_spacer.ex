defprotocol Satie.ToSpacer do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToSpacer, for: Any do
  def from(x), do: {:error, :spacer_new, x}
end

defimpl Satie.ToSpacer, for: Satie.Spacer do
  def from(rest), do: rest
end

for leaf <- [Satie.Chord, Satie.Note, Satie.Rest] do
  defimpl Satie.ToSpacer, for: leaf do
    def from(%{written_duration: duration}) do
      @protocol.from(duration)
    end
  end
end

defimpl Satie.ToSpacer, for: Satie.Duration do
  def from(duration) do
    case Satie.Duration.printable?(duration) do
      true ->
        %Satie.Spacer{
          written_duration: duration
        }

      false ->
        {:error, :spacer_new, {:unassignable_duration, duration}}
    end
  end
end

defimpl Satie.ToSpacer, for: BitString do
  def from(spacer) do
    case Satie.Lilypond.Parser.spacer().(spacer) do
      {:ok, duration, ""} -> @protocol.from(Satie.Duration.new(duration))
      _ -> {:error, :spacer_new, spacer}
    end
  end
end

defimpl Satie.ToSpacer, for: Tuple do
  import Satie.Guards

  def from(duration) when is_integer_duple(duration) do
    Satie.Duration.new(duration)
    |> @protocol.from()
  end
end

defimpl Satie.ToSpacer, for: Integer do
  def from(numerator), do: @protocol.from({numerator, 1})
end
