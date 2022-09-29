defmodule Satie.PitchClass do
  defstruct [:name, :accidental, :semitones, :diatonic_pitch_class]

  alias Satie.Accidental
  import Satie.PitchHelpers

  @re ~r/^
    (?<diatonic_pitch_class>[abcdefg])
    (?<accidental>(t?q[sf]|s+(qs)?|f+(qf)?|\+|~)?)
  $/x

  def new(pitch_class) when is_bitstring(pitch_class) do
    case Regex.named_captures(@re, pitch_class) do
      nil ->
        {:error, :pitch_class_new, pitch_class}

      captures ->
        captures
        |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v} end)
        |> build_accidental()
        |> build_name()
        |> calculate_semitones()
        |> then(&struct(__MODULE__, &1))
    end
  end

  def alteration(%__MODULE__{accidental: %Accidental{semitones: semitones}}), do: semitones

  defp build_accidental(%{accidental: accidental} = map) do
    %{map | accidental: Accidental.new(accidental)}
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
