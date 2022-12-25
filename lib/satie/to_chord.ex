defprotocol Satie.ToChord do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToChord, for: Any do
  def from(x), do: {:error, :chord_new, x}
end

defimpl Satie.ToChord, for: Satie.Chord do
  def from(chord), do: chord
end

for leaf <- [Satie.Note, Satie.Rest, Satie.Spacer] do
  defimpl Satie.ToChord, for: leaf do
    def from(%{written_duration: duration}) do
      @protocol.from({[Satie.Notehead.new("c'")], duration})
    end
  end
end

defimpl Satie.ToChord, for: BitString do
  def from(chord) do
    case Satie.Lilypond.Parser.chord().(chord) do
      {:ok, [noteheads, duration], ""} ->
        noteheads = Enum.map(noteheads, &Satie.Notehead.new/1)
        duration = Satie.Duration.new(duration)
        @protocol.from({noteheads, duration})

      _ ->
        {:error, :chord_new, chord}
    end
  end
end

defimpl Satie.ToChord, for: Tuple do
  def from({noteheads, duration}) do
    noteheads = Enum.map(noteheads, &Satie.Notehead.new/1)
    duration = Satie.Duration.new(duration)

    with :ok <- validate_noteheads(noteheads),
         true <- Satie.Duration.printable?(duration) do
      %Satie.Chord{
        noteheads: noteheads,
        written_duration: duration
      }
    else
      _ -> {:error, :chord_new, {noteheads, duration}}
    end
  end

  defp validate_noteheads([]), do: :error
  defp validate_noteheads(noteheads), do: do_validate_noteheads(noteheads)

  defp do_validate_noteheads([]), do: :ok
  defp do_validate_noteheads([%Satie.Notehead{} | rest]), do: do_validate_noteheads(rest)
  defp do_validate_noteheads([_ | _]), do: :error
end
