defprotocol Satie.ToNote do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToNote, for: Any do
  def from(x), do: {:error, :note_new, x}
end

defimpl Satie.ToNote, for: Satie.Note do
  def from(note), do: note
end

defimpl Satie.ToNote, for: BitString do
  def from(note) when is_bitstring(note) do
    case Satie.Lilypond.Parser.note().(note) do
      {:ok, [notehead, duration], ""} ->
        @protocol.from({notehead, duration})

      _ ->
        {:error, :note_new, note}
    end
  end
end

defimpl Satie.ToNote, for: Tuple do
  def from({notehead, duration}) do
    duration = Satie.Duration.new(duration)

    case Satie.Duration.printable?(duration) do
      true ->
        %Satie.Note{
          notehead: Satie.Notehead.new(notehead),
          written_duration: duration
        }

      false ->
        {:error, :note_new, {:unassignable_duration, duration}}
    end
  end
end
