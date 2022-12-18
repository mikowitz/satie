defmodule Satie.Duration do
  @moduledoc """
  Models a time duration
  """
  defstruct [:numerator, :denominator]

  import Satie.Guards

  alias Satie.Fractional
  alias Satie.Multiplier

  @duration_re ~r/^(?<base>\\breve|\\longa|\\maxima|\d+)(?<dots>.*)$/

  def new(duration) when is_bitstring(duration) do
    case Regex.named_captures(@duration_re, duration) do
      %{"base" => base, "dots" => dots} ->
        dots_count = String.length(dots)
        {n, base} = parse_base_duration(base)

        {numerator, denominator} = build_numerator_and_denominator(n, base, dots_count)
        new(numerator, denominator)

      nil ->
        {:error, :duration_new, duration}
    end
  end

  def new(numerator, denominator)
      when is_integer(numerator) and is_integer(denominator) and denominator != 0 do
    {numerator, denominator}
    |> Fractional.__init__(__MODULE__)
  end

  def new(n, d), do: {:error, :duration_new, {n, d}}

  def printable?(%__MODULE__{} = duration) do
    [&proper_length?/1, &printable_subdivision?/1, &not_tied?/1]
    |> Enum.all?(& &1.(duration))
  end

  def add(%__MODULE__{} = duration, rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)
    new(n1 * d2 + n2 * d1, d1 * d2)
  end

  def subtract(%__MODULE__{} = duration, rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)
    new(n1 * d2 - n2 * d1, d1 * d2)
  end

  def multiply(%__MODULE__{} = duration, rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)
    new(n1 * n2, d1 * d2)
  end

  def multiply(%__MODULE__{} = duration, rhs) when is_integer(rhs) do
    {n, d} = Fractional.to_tuple(duration)
    new(n * rhs, d)
  end

  def divide(%__MODULE__{} = duration, rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)
    Multiplier.new(n1 * d2, n2 * d1)
  end

  def divide(%__MODULE__{} = duration, rhs) when is_integer(rhs) and rhs != 0 do
    {n, d} = Fractional.to_tuple(duration)
    new(n, d * rhs)
  end

  defp proper_length?(%__MODULE__{numerator: n, denominator: d}) do
    f = n / d
    0 < f && f < 16
  end

  defp printable_subdivision?(%__MODULE__{denominator: d}) do
    Bitwise.band(d, d - 1) == 0
  end

  defp not_tied?(%__MODULE__{numerator: n}) do
    binary = Integer.to_string(n, 2)
    !Regex.match?(~r/01/, binary)
  end

  defp parse_base_duration("\\breve"), do: {2, 1}
  defp parse_base_duration("\\longa"), do: {4, 1}
  defp parse_base_duration("\\maxima"), do: {8, 1}

  defp parse_base_duration(dur) do
    {dur, ""} = Integer.parse(dur)
    {1, dur}
  end

  defp build_numerator_and_denominator(1, base, dots_count) do
    {
      round(:math.pow(2, dots_count + 1) - 1),
      round(:math.pow(2, :math.log2(base) + dots_count))
    }
  end

  defp build_numerator_and_denominator(num, _base, 0) do
    {num, 1}
  end

  defp build_numerator_and_denominator(num, _base, dots_count) do
    {
      round(:math.pow(2, dots_count + 1) - 1),
      round(:math.pow(2, dots_count) / num)
    }
  end

  defimpl String.Chars do
    def to_string(%@for{} = duration) do
      case Satie.to_lilypond(duration) do
        ly when is_bitstring(ly) -> String.replace(ly, "\\", "")
        {:error, :unprintable_duration, {n, d}} -> "(#{n},#{d})"
      end
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = duration, _opts) do
      concat([
        "#Satie.Duration<",
        to_string(duration),
        ">"
      ])
    end
  end

  def to_float(%__MODULE__{numerator: n, denominator: d}), do: n / d

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{numerator: n, denominator: d} = duration, _opts) do
      case @for.printable?(duration) do
        false -> {:error, :unprintable_duration, {n, d}}
        true -> base_duration_string(duration) <> dots(duration)
      end
    end

    defp base_duration_string(%@for{denominator: d} = duration) do
      case @for.to_float(duration) do
        n when n >= 8 -> "\\maxima"
        n when n >= 4 -> "\\longa"
        n when n >= 2 -> "\\breve"
        _ -> :math.pow(2, :math.log2(d) - dots_count(duration)) |> round() |> to_string()
      end
    end

    defp dots_count(%@for{numerator: n}) do
      Integer.to_string(n, 2)
      |> String.split("", trim: true)
      |> Enum.drop(1)
      |> Enum.count(&(&1 == "1"))
    end

    defp dots(%@for{} = duration), do: String.duplicate(".", dots_count(duration))
  end
end
