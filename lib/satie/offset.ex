defmodule Satie.Offset do
  @moduledoc """
  Models a temporal offset as a rational fraction
  """

  # alias Satie.Fractional
  use Satie.Fractional
  alias Satie.{Duration, Multiplier}
  import Satie.Guards

  defstruct [:numerator, :denominator]

  @doc """

      iex> Offset.new(0)
      #Satie.Offset<{0, 1}>

      iex> Offset.new(3, 16)
      #Satie.Offset<{3, 16}>

      iex> Offset.new({5, 18})
      #Satie.Offset<{5, 18}>

    Reduces fraction

      iex> Offset.new(4, 16)
      #Satie.Offset<{1, 4}>


    Can initialize from another Offset

      iex> offset = Offset.new(1, 3)
      iex> Offset.new(offset)
      #Satie.Offset<{1, 3}>

  """
  def new(offset), do: Satie.ToOffset.from(offset)

  def new(numerator, denominator) do
    new({numerator, denominator})
  end

  @doc """

      iex> offset = Offset.new(7, 4)
      iex> Offset.to_float(offset)
      1.75

  """
  def to_float(%__MODULE__{numerator: n, denominator: d}), do: n / d

  def add(%__MODULE__{} = duration, rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)
    new(n1 * d2 + n2 * d1, d1 * d2)
  end

  def subtract(%__MODULE__{} = duration, %rhs_struct{} = rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)

    case rhs_struct do
      __MODULE__ -> Duration.new(n1 * d2 - n2 * d1, d1 * d2)
      _ -> new(n1 * d2 - n2 * d1, d1 * d2)
    end
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

  def divide(%__MODULE__{} = duration, %rhs_struct{} = rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)

    case rhs_struct do
      __MODULE__ -> Multiplier.new(n1 * d2, n2 * d1)
      _ -> new(n1 * d2, n2 * d1)
    end
  end

  def divide(%__MODULE__{} = duration, rhs) when is_integer(rhs) and rhs != 0 do
    {n, d} = Fractional.to_tuple(duration)
    new(n, d * rhs)
  end

  def eq(%__MODULE__{} = offset1, %__MODULE__{} = offset2) do
    to_float(offset1) == to_float(offset2)
  end

  def gt(%__MODULE__{} = offset1, %__MODULE__{} = offset2) do
    to_float(offset1) > to_float(offset2)
  end

  def gte(%__MODULE__{} = offset1, %__MODULE__{} = offset2) do
    to_float(offset1) >= to_float(offset2)
  end

  def lt(%__MODULE__{} = offset1, %__MODULE__{} = offset2) do
    to_float(offset1) < to_float(offset2)
  end

  def lte(%__MODULE__{} = offset1, %__MODULE__{} = offset2) do
    to_float(offset1) <= to_float(offset2)
  end

  defimpl String.Chars do
    def to_string(%@for{numerator: n, denominator: d}) do
      "Offset({#{n}, #{d}})"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra
    alias Satie.Fractional

    def inspect(%@for{} = offset, _opts) do
      concat([
        "#Satie.Offset<",
        inspect(Fractional.to_tuple(offset)),
        ">"
      ])
    end
  end
end
