defmodule Satie.Duration do
  @moduledoc """
  Models a time duration
  """
  defstruct [:numerator, :denominator]

  import Satie.Guards

  alias Satie.{Fraction, Multiplier, Offset}

  use Satie.Fractional

  use Satie.Fractional.Math,
    add: [{Fraction, Fraction}],
    subtract: [{Fraction, Fraction}],
    multiply: [{Fraction, Fraction}],
    divide: [
      {__MODULE__, Multiplier},
      {Fraction, Fraction},
      {Multiplier, Multiplier},
      {Offset, Multiplier}
    ]

  @doc """

      iex> Duration.new(2)
      #Satie.Duration<breve>

      iex> duration = Duration.new(1, 4)
      iex> Duration.new(duration)
      #Satie.Duration<4>

  """
  def new(duration) do
    Satie.ToDuration.from(duration)
  end

  def new(numerator, denominator) do
    new({numerator, denominator})
  end

  def printable?(%__MODULE__{} = duration) do
    [&proper_length?/1, &printable_subdivision?/1, &not_tied?/1]
    |> Enum.all?(& &1.(duration))
  end

  def equal_or_shorter_printable(%__MODULE__{numerator: n, denominator: d} = duration) do
    case printable?(duration) do
      true -> duration
      false -> equal_or_shorter_printable(new(n - 1, d))
    end
  end

  def make_printable_tied_duration(%__MODULE__{} = duration) do
    case printable?(duration) do
      true ->
        [duration]

      false ->
        first_printable = equal_or_shorter_printable(duration)
        remainder = subtract(duration, first_printable)
        [first_printable | make_printable_tied_duration(remainder)]
    end
  end

  def sum(durations) when is_list(durations) do
    Enum.reduce(durations, new(0), &add/2)
  end

  def negative?(%__MODULE__{numerator: n}) when n < 0, do: true
  def negative?(%__MODULE__{}), do: false

  def negate(%__MODULE__{numerator: n, denominator: d}) do
    new(-n, d)
  end

  def abs(%__MODULE__{numerator: n, denominator: d}) do
    new(Kernel.abs(n), d)
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
