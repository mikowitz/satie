defprotocol Satie.ToNotehead do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToNotehead, for: Any do
  def from(x), do: {:error, :notehead_new, x}
end

defimpl Satie.ToNotehead, for: Satie.Notehead do
  def from(notehead), do: notehead
end

defimpl Satie.ToNotehead, for: Satie.Pitch do
  def from(pitch), do: @protocol.from({pitch, :neutral})
end

defimpl Satie.ToNotehead, for: BitString do
  def from(notehead) do
    case Satie.Lilypond.Parser.notehead().(notehead) do
      {:ok, [pitch, accidental_display], ""} ->
        @protocol.from({pitch, accidental_display})

      _ ->
        {:error, :notehead_new, notehead}
    end
  end
end

defimpl Satie.ToNotehead, for: Tuple do
  def from({pitch, opts}) do
    pitch = Satie.Pitch.new(pitch)
    accidental_display = map_to_accidental_display(opts)

    %Satie.Notehead{
      written_pitch: pitch,
      accidental_display: accidental_display
    }
  end

  defp map_to_accidental_display(opts) when is_list(opts) do
    Keyword.get(opts, :accidental_display, :neutral)
    |> map_to_accidental_display()
  end

  defp map_to_accidental_display(:cautionary), do: :cautionary
  defp map_to_accidental_display(:forced), do: :forced
  defp map_to_accidental_display("?"), do: :cautionary
  defp map_to_accidental_display("!"), do: :forced
  defp map_to_accidental_display(_), do: :neutral
end
