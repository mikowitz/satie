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
  @pitch_re ~r/^(?<pitch>[^?!]+)(?<accidental_display>[?!]?)$/

  def from(notehead) do
    parse_pitch_and_accidental_display(notehead)
    |> @protocol.from()
  end

  defp parse_pitch_and_accidental_display(pitch) do
    %{"pitch" => pitch, "accidental_display" => accidental_display} =
      Regex.named_captures(@pitch_re, pitch)

    {pitch, translate_accidental_display(accidental_display)}
  end

  defp translate_accidental_display("?"), do: :cautionary
  defp translate_accidental_display("!"), do: :forced
  defp translate_accidental_display(""), do: :neutral
end

defimpl Satie.ToNotehead, for: Tuple do
  def from({pitch, opts}) do
    pitch = Satie.Pitch.new(pitch)
    accidental_display = fetch_accidental_display_from(opts)

    %Satie.Notehead{
      written_pitch: pitch,
      accidental_display: accidental_display
    }
  end

  defp fetch_accidental_display_from(opts) when is_list(opts) do
    Keyword.get(opts, :accidental_display, :neutral)
    |> fetch_accidental_display_from()
  end

  defp fetch_accidental_display_from(:cautionary), do: :cautionary
  defp fetch_accidental_display_from(:forced), do: :forced
  defp fetch_accidental_display_from("?"), do: :cautionary
  defp fetch_accidental_display_from("!"), do: :forced
  defp fetch_accidental_display_from(_), do: :neutral
end
