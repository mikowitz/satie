defmodule Satie.Pitch do
  @moduledoc """
  Models a musical pitch
  """
  defstruct [:name, :pitch_class, :semitones, :octave]

  alias Satie.{Accidental, Interval, PitchClass}

  import Satie.Helpers,
    only: [
      polarity_to_string: 1,
      sign: 1
    ]

  import Satie.PitchHelpers

  @re ~r/^
    (?<pitch_class>[abcdefg](t?q[sf]|s+(qs)?|f+(qf)?|\+|~)?)
    (?<octave>,*|'*)
  $/x

  def new(pitch) when is_bitstring(pitch) do
    case Regex.named_captures(@re, pitch) do
      nil ->
        {:error, :pitch_new, pitch}

      captures ->
        captures
        |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v} end)
        |> build_pitch_class()
        |> build_name()
        |> parse_octave()
        |> calculate_semitones()
        |> then(&struct(__MODULE__, &1))
    end
  end

  def add(%__MODULE__{} = pitch, %__MODULE__{} = rhs) do
    transpose(pitch, to_interval(rhs))
  end

  def transpose(%__MODULE__{} = pitch, %Interval{} = rhs) do
    %{pitch: pitch, interval: rhs}
    |> calculate_total_semitones()
    |> calculate_diatonic_pitch_class()
    |> calculate_accidental()
    |> calculate_octaves()
    |> build_pitch_string()
    |> new()
  end

  def to_interval(%__MODULE__{} = pitch) do
    with number <- pitch.semitones do
      %{
        semitones: :math.fmod(abs(number), 12),
        polarity: sign(number),
        octaves: floor(abs(number) / 12)
      }
      |> calculate_semitones_and_quartertone()
      |> calculate_quality_and_diatonic_number()
      |> build_interval_name()
      |> Interval.new()
    end
  end

  def subtract(%__MODULE__{} = pitch, %__MODULE__{} = rhs) do
    %{pitch: pitch, rhs: rhs}
    |> calculate_staff_spaces_and_semitones()
    |> calculate_named_interval_data()
    |> calculate_numbered_interval_data()
    |> calculate_named_interval_class_and_octaves()
    |> calculate_numbered_interval_class_and_quartertone()
    |> calculate_quality()
    |> calculate_polarity()
    |> build_interval_name()
    |> Interval.new()
  end

  def invert(%__MODULE__{} = pitch, %__MODULE__{} = axis) do
    transpose(axis, subtract(pitch, axis))
  end

  defp calculate_semitones_and_quartertone(%{semitones: semitones} = map) do
    {semitones, quartertone} =
      case :math.fmod(semitones, 1) do
        0.0 -> {semitones, ""}
        _ -> {semitones - 0.5, "+"}
      end

    %{map | semitones: semitones}
    |> Map.put_new(:quartertone, quartertone)
  end

  defp calculate_quality_and_diatonic_number(
         %{semitones: semitones, quartertone: quartertone, octaves: octaves} = map
       ) do
    {quality, diatonic_number} = semitones_to_quality_and_diatonic_number(round(semitones))

    Map.put_new(map, :quality, quality <> quartertone)
    |> Map.put_new(:diatonic_number, diatonic_number + octaves * 7)
  end

  defp build_interval_name(%{
         polarity: polarity,
         quality: quality,
         diatonic_number: diatonic_number
       }) do
    polarity_to_string(polarity) <> quality <> to_string(diatonic_number)
  end

  defp calculate_total_semitones(%{pitch: pitch, interval: interval} = map) do
    Map.put_new(map, :total_semitones, pitch.semitones + interval.semitones)
  end

  defp calculate_diatonic_pitch_class(
         %{pitch: %{pitch_class: pitch_class}, interval: interval} = map
       ) do
    diatonic_pc_staff_spaces = dpc_to_staff_spaces(pitch_class.diatonic_pitch_class)
    staff_spaces = diatonic_pc_staff_spaces + interval.staff_spaces
    staff_spaces = Integer.mod(staff_spaces, 7)

    diatonic_pc_name = staff_spaces_to_dpc(staff_spaces)

    Map.put_new(map, :diatonic_pitch_class, diatonic_pc_name)
  end

  defp calculate_accidental(%{diatonic_pitch_class: dpc, total_semitones: total_semitones} = map) do
    dpc_semitones = dpc_to_semitones(dpc)
    nearest_neighbor = normalize_octave(total_semitones, dpc_semitones)
    acc_semitones = total_semitones - nearest_neighbor
    Map.put_new(map, :accidental, Accidental.new(acc_semitones))
  end

  defp calculate_octaves(%{total_semitones: total_semitones, accidental: accidental} = map) do
    octaves = round(floor((total_semitones - accidental.semitones) / 12)) + 4
    Map.put_new(map, :octaves, octaves)
  end

  defp build_pitch_string(%{diatonic_pitch_class: dpc, accidental: acc, octaves: octaves}) do
    acc_name =
      case acc.name do
        "natural" -> ""
        name -> name
      end

    dpc <> acc_name <> octave_to_string(octaves)
  end

  defp normalize_octave(pitch_number, pc_number) do
    target_pc = mod(pitch_number, 12)
    down = mod(target_pc - pc_number, 12)
    up = mod(pc_number - target_pc, 12)

    case up < down do
      true -> pitch_number + up
      false -> pitch_number - down
    end
  end

  defp build_pitch_class(%{pitch_class: pc} = map) do
    %{map | pitch_class: PitchClass.new(pc)}
  end

  defp build_name(%{pitch_class: %{name: name}, octave: octave} = map) do
    Map.put_new(map, :name, name <> octave)
  end

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
        PitchClass.alteration(pitch_class) +
        (octave - 4) * 12

    Map.put_new(map, :semitones, semitones)
  end

  defp should_reverse_polarity?(pitch, rhs) do
    p_dpn = get_staff_spaces(pitch)
    rhs_dpn = get_staff_spaces(rhs)

    case p_dpn == rhs_dpn do
      false ->
        p_dpn < rhs_dpn

      true ->
        pitch.pitch_class.accidental.semitones < rhs.pitch_class.accidental.semitones
    end
  end

  defp get_staff_spaces(%__MODULE__{octave: octave, pitch_class: pitch_class}) do
    7 * (octave - 4) + dpc_to_staff_spaces(pitch_class.diatonic_pitch_class)
  end

  defp to_octave_and_diatonic_remainder(number) do
    octaves = div(number - 1, 7)
    remainder = number - 7 * octaves
    {octaves, remainder}
  end

  defp calculate_staff_spaces_and_semitones(%{pitch: pitch, rhs: rhs} = map) do
    Map.put_new(map, :staff_spaces, get_staff_spaces(pitch) - get_staff_spaces(rhs))
    |> Map.put_new(:semitones, pitch.semitones - rhs.semitones)
  end

  defp calculate_named_interval_data(%{staff_spaces: staff_spaces} = map) do
    named_interval = %{
      sign: sign(staff_spaces),
      number: abs(staff_spaces) + 1
    }

    Map.put_new(map, :named_interval, named_interval)
    |> Map.put_new(:diatonic_number, named_interval.number)
  end

  defp calculate_numbered_interval_data(%{semitones: semitones} = map) do
    numbered_interval = %{
      sign: sign(semitones),
      number: abs(semitones)
    }

    Map.put_new(map, :numbered_interval, numbered_interval)
  end

  defp calculate_named_interval_class_and_octaves(%{named_interval: %{number: number}} = map) do
    {octaves, named_interval_class} = to_octave_and_diatonic_remainder(number)

    Map.put_new(map, :octaves, octaves)
    |> Map.put_new(:named_interval_class, named_interval_class)
  end

  defp calculate_numbered_interval_class_and_quartertone(
         %{
           numbered_interval: numbered,
           named_interval: named,
           octaves: octaves
         } = map
       ) do
    %{number: numbered_number, sign: numbered_sign} = numbered
    %{sign: named_sign} = named

    numbered_interval_class = numbered_number - 12 * octaves

    numbered_interval_class =
      case named_sign != 0 && named_sign == -numbered_sign do
        true -> numbered_interval_class * -1
        false -> numbered_interval_class
      end

    {numbered_interval_class, quartertone} =
      case :math.fmod(numbered_interval_class, 1) do
        0.0 -> {numbered_interval_class, ""}
        _ -> {numbered_interval_class - 0.5, "+"}
      end

    Map.put_new(map, :numbered_interval_class, numbered_interval_class)
    |> Map.put_new(:quartertone, quartertone)
  end

  defp calculate_quality(
         %{
           named_interval_class: named_interval_class,
           numbered_interval_class: numbered_interval_class,
           quartertone: quartertone
         } = map
       ) do
    quality_to_semitones_map = diatonic_number_to_quality_dictionary(named_interval_class)

    {min, max} = Enum.min_max(Map.values(quality_to_semitones_map))

    quality =
      case numbered_interval_class do
        n when n > max ->
          String.duplicate("A", round(n - max) + 1)

        n when n < min ->
          String.duplicate("d", round(abs(min - n) + 1))

        n ->
          Enum.find(quality_to_semitones_map, fn {_k, v} -> v == n end)
          |> elem(0)
      end

    Map.put_new(map, :quality, quality <> quartertone)
  end

  defp calculate_polarity(%{pitch: pitch, rhs: rhs} = map) do
    polarity =
      case should_reverse_polarity?(rhs, pitch) do
        true -> -1
        false -> 1
      end

    Map.put_new(map, :polarity, polarity)
  end

  defp mod(a, b) do
    case :math.fmod(a, b) do
      n when n < 0 -> n + b
      n -> n
    end
  end

  defp octave_to_string(3), do: ""
  defp octave_to_string(o) when o > 3, do: String.duplicate("'", o - 3)
  defp octave_to_string(o) when o < 3, do: String.duplicate(",", 3 - o)

  defimpl String.Chars do
    def to_string(%@for{name: name}), do: name
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = pitch, _opts) do
      concat([
        "#Satie.Pitch<",
        to_string(pitch),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = pitch) do
      to_string(pitch)
    end
  end
end
