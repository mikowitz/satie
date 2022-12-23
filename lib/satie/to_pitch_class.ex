defprotocol Satie.ToPitchClass do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToPitchClass, for: Any do
  def from(x), do: {:error, :pitch_class_new, x}
end

defimpl Satie.ToPitchClass, for: Satie.PitchClass do
  def from(pitch_class), do: pitch_class
end

defimpl Satie.ToPitchClass, for: BitString do
  @re ~r/^
    (?<diatonic_pitch_class>[abcdefg])
    (?<accidental>(t?q[sf]|s+(qs)?|f+(qf)?|\+|~)?)
  $/x

  def from(pitch_class) do
    case Regex.named_captures(@re, pitch_class) do
      nil -> {:error, :pitch_class_new, pitch_class}
      %{"diatonic_pitch_class" => dpc, "accidental" => acc} -> @protocol.from({dpc, acc})
    end
  end
end

defimpl Satie.ToPitchClass, for: Tuple do
  import Satie.PitchHelpers, only: [dpc_to_semitones: 1]

  def from({diatonic_pitch_class, accidental}) do
    %{diatonic_pitch_class: diatonic_pitch_class, accidental: accidental}
    |> build_accidental()
    |> build_name()
    |> calculate_semitones()
    |> then(&struct(Satie.PitchClass, &1))
  end

  def from(tuple), do: {:error, :pitch_class_new, tuple}

  defp build_accidental(%{accidental: accidental} = map) do
    %{map | accidental: Satie.Accidental.new(accidental)}
  end

  defp build_name(%{diatonic_pitch_class: dpc, accidental: acc} = map) do
    name =
      case acc.name do
        "natural" -> dpc
        acc_name -> dpc <> acc_name
      end

    Map.put_new(map, :name, name)
  end

  defp calculate_semitones(%{accidental: acc, diatonic_pitch_class: dpc} = map) do
    semitones = acc.semitones + dpc_to_semitones(dpc)

    semitones =
      case semitones do
        s when s < 0 -> s + 12
        s when s >= 12 -> :math.fmod(s, 12)
        _ -> semitones
      end

    Map.put_new(map, :semitones, semitones)
  end
end
