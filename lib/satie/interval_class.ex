defmodule Satie.IntervalClass do
  defstruct [:name, :size, :quality, :polarity]

  @re ~r/^
    (?<polarity>[-+]?)
    (?<quality>m|M|P|d+|A+)
    (?<quartertone>[~+]?)
    (?<size>\d+)
    $/x

  @size_to_quality %{
    1 => ~w(d P A),
    2 => ~w(d m M A),
    3 => ~w(d m M A),
    4 => ~w(d P A),
    5 => ~w(d P A),
    6 => ~w(d m M A),
    7 => ~w(d m M A),
    8 => ~w(d P A)
  }

  def new(interval_class) when is_bitstring(interval_class) do
    case Regex.named_captures(@re, interval_class) do
      nil ->
        {:error, :interval_class_new, interval_class}

      captures ->
        captures
        |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v} end)
        |> parse_polarity()
        |> parse_size()
        |> validate_quality()
        |> then(fn
          {:error, _, _} = error ->
            error

          %{} = map ->
            map
            |> append_quartertone_to_quality()
            |> correct_size_and_polarity()
            |> build_name()
            |> then(&struct(__MODULE__, &1))
        end)
    end
  end

  defp parse_polarity(%{polarity: "-"} = map), do: %{map | polarity: -1}
  defp parse_polarity(%{polarity: _} = map), do: %{map | polarity: 1}

  defp parse_size(%{size: size} = map) do
    {size, ""} = Integer.parse(size)
    %{map | size: size}
  end

  defp validate_quality(%{quality: quality, size: size} = map) do
    size = normalize_size(size)

    case String.first(quality) in @size_to_quality[size] do
      true -> map
      false -> {:error, :interval_class_invalid_quality, {quality, size}}
    end
  end

  defp append_quartertone_to_quality(%{quartertone: quartertone, quality: quality} = map) do
    %{map | quality: quality <> quartertone}
    |> Map.delete(:quartertone)
  end

  defp build_name(%{quality: quality, size: size, polarity: polarity} = map) do
    Map.put(map, :name, "#{polarity_to_string(polarity)}#{quality}#{abs(size)}")
  end

  defp correct_size_and_polarity(%{size: size, polarity: polarity} = map) do
    normal_size = normalize_size(size)

    {new_size, new_polarity} =
      case is_octave?(map, normal_size) do
        true ->
          cond do
            is_perfect?(map) -> {8, polarity}
            is_diminished_or_quarter_flat?(map) -> {normal_size, -polarity}
            true -> {normal_size, polarity}
          end

        false ->
          {normal_size, polarity}
      end

    {new_size, new_polarity} =
      case is_perfect_unison?(map) do
        true -> {new_size, 0}
        false -> {new_size * new_polarity, new_polarity}
      end

    %{map | size: new_size, polarity: new_polarity}
  end

  defp is_perfect_unison?(%{quality: "P", size: 1}), do: true
  defp is_perfect_unison?(_), do: false

  defp is_octave?(%{size: size}, 1) when size >= 8, do: true
  defp is_octave?(_, _), do: false

  defp is_perfect?(%{quality: "P"}), do: true
  defp is_perfect?(_), do: false

  defp is_diminished_or_quarter_flat?(%{quality: "d" <> _}), do: true
  defp is_diminished_or_quarter_flat?(%{quality: "P~"}), do: true
  defp is_diminished_or_quarter_flat?(_), do: false

  defp polarity_to_string(-1), do: "-"
  defp polarity_to_string(1), do: "+"
  defp polarity_to_string(0), do: ""

  defp normalize_size(size) when size > 7, do: normalize_size(size - 7)
  defp normalize_size(size), do: size
end
