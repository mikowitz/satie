defprotocol Satie.ToPitch do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToPitch, for: Any do
  def from(x), do: {:error, :pitch_new, x}
end

defimpl Satie.ToPitch, for: Satie.Pitch do
  def from(pitch), do: pitch
end

defimpl Satie.ToPitch, for: BitString do
  @re ~r/^
    (?<pitch_class>[abcdefg](t?q[sf]|s+(qs)?|f+(qf)?|\+|~)?)
    (?<octave>,*|'*)
  $/x

  def from(pitch) do
    case Regex.named_captures(@re, pitch) do
      nil -> {:error, :pitch_new, pitch}
      %{"pitch_class" => pitch_class, "octave" => octave} -> @protocol.from({pitch_class, octave})
    end
  end
end

defimpl Satie.ToPitch, for: Tuple do
  import Satie.PitchHelpers, only: [dpc_to_semitones: 1]

  def from({pitch_class, octave}) do
    %{pitch_class: pitch_class, octave: octave}
    |> build_pitch_class()
    |> parse_octave()
    |> build_name()
    |> calculate_semitones()
    |> then(&struct(Satie.Pitch, &1))
  end

  defp build_pitch_class(%{pitch_class: pc} = map) do
    %{map | pitch_class: Satie.PitchClass.new(pc)}
  end

  defp build_name(%{pitch_class: %{name: name}, octave: octave} = map) do
    Map.put_new(map, :name, name <> octave_to_string(octave))
  end

  defp parse_octave(%{octave: octave} = map) when is_integer(octave), do: map

  defp parse_octave(%{octave: ""} = map), do: %{map | octave: 3}

  defp parse_octave(%{octave: "'" <> _ = octave} = map),
    do: %{map | octave: 3 + String.length(octave)}

  defp parse_octave(%{octave: "," <> _ = octave} = map),
    do: %{map | octave: 3 - String.length(octave)}

  defp calculate_semitones(
         %{octave: octave, pitch_class: %{diatonic_pitch_class: dpc} = pitch_class} = map
       ) do
    semitones =
      dpc_to_semitones(dpc) +
        Satie.PitchClass.alteration(pitch_class) +
        (octave - 4) * 12

    Map.put_new(map, :semitones, semitones)
  end

  defp octave_to_string(3), do: ""
  defp octave_to_string(o) when o > 3, do: String.duplicate("'", o - 3)
  defp octave_to_string(o) when o < 3, do: String.duplicate(",", 3 - o)
end
