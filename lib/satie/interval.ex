defmodule Satie.Interval do
  defstruct ~w(interval_class name size polarity octaves quality semitones staff_spaces)a

  alias Satie.IntervalClass
  import Satie.Helpers

  def new(interval) when is_bitstring(interval) do
    case Regex.named_captures(interval_regex(), interval) do
      nil ->
        {:error, :interval_new, interval}

      captures ->
        captures
        |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v} end)
        |> parse_polarity()
        |> parse_size()
        |> validate_quality(:interval)
        |> then(fn
          {:error, _, _} = error ->
            error

          %{} = map ->
            map
            |> calculate_octaves()
            |> correct_size_and_polarity()
            |> calculate_semitones()
            |> append_quartertone_to_quality()
            |> build_name()
            |> construct_interval_class()
            |> calculate_staff_spaces()
            |> then(&struct(__MODULE__, &1))
        end)
    end
  end

  def negate(%__MODULE__{name: "+" <> name}), do: new("-" <> name)
  def negate(%__MODULE__{name: "-" <> name}), do: new("+" <> name)
  def negate(%__MODULE__{} = interval), do: interval

  defp calculate_octaves(%{size: size} = map) do
    {normal_size, octaves} = normalize_size_with_octaves(size, 0)

    octaves =
      case is_octave?(map, normal_size) && is_perfect?(map) do
        true -> octaves - 1
        false -> octaves
      end

    Map.put_new(map, :octaves, octaves)
  end

  defp correct_size_and_polarity(%{size: size, polarity: polarity} = map) do
    {size, polarity} =
      case is_perfect_unison?(map) && map.quartertone == "" do
        true -> {size, 0}
        false -> {size * polarity, polarity}
      end

    %{map | size: size, polarity: polarity}
  end

  defp construct_interval_class(%{quality: quality, polarity: polarity} = map) do
    size = normalize_size_accounting_for_perfect_octave(map)

    interval_class =
      IntervalClass.new(polarity_to_string(polarity) <> quality <> to_string(abs(size)))

    Map.put_new(map, :interval_class, interval_class)
  end

  defp calculate_semitones(
         %{
           size: size,
           octaves: octaves,
           quality: quality,
           quartertone: quartertone,
           polarity: polarity
         } = map
       ) do
    normal_size = normalize_size_accounting_for_perfect_octave(map)

    semitones =
      size_to_semitones(normal_size) + quality_to_semitones(normal_size, quality) +
        quartertone_string_to_number(quartertone)

    semitones = if abs(size) == 1, do: abs(semitones), else: semitones + octaves * 12
    Map.put_new(map, :semitones, semitones * polarity)
  end

  defp calculate_staff_spaces(%{size: size, polarity: polarity} = map) do
    Map.put_new(map, :staff_spaces, (abs(size) - 1) * polarity)
  end

  defp normalize_size_with_octaves(size, octaves) when size > 7 do
    normalize_size_with_octaves(size - 7, octaves + 1)
  end

  defp normalize_size_with_octaves(size, octaves), do: {size, octaves}

  defp normalize_size_accounting_for_perfect_octave(%{size: size} = map) do
    normal_size = normalize_size(abs(size))

    case is_octave?(map, normal_size) && is_perfect?(map) do
      true -> 8
      false -> normal_size
    end
  end
end
