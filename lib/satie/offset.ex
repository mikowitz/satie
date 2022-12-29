defmodule Satie.Offset do
  @moduledoc """
  Models a temporal offset as a rational fraction
  """

  # alias Satie.Fractional
  use Satie.Fractional
  alias Satie.{Duration, Fraction, Multiplier}
  import Satie.Guards

  defstruct [:numerator, :denominator]

  @doc """

      iex> Offset.new(0)
      #Satie.Offset<0/1>

      iex> Offset.new(3, 16)
      #Satie.Offset<3/16>

      iex> Offset.new({5, 18})
      #Satie.Offset<5/18>

    Reduces fraction

      iex> Offset.new(4, 16)
      #Satie.Offset<1/4>

    Can initialize from another Offset

      iex> offset = Offset.new(1, 3)
      iex> Offset.new(offset)
      #Satie.Offset<1/3>

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

  use Satie.Fractional.Math,
    add: [{Fraction, Fraction}],
    subtract: [
      {__MODULE__, Duration},
      {Fraction, Duration}
    ],
    multiply: [{Fraction, Fraction}],
    divide: [
      {__MODULE__, Multiplier},
      {Fraction, Fraction}
    ]

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

    def inspect(%@for{numerator: n, denominator: d}, _opts) do
      concat([
        "#Satie.Offset<",
        "#{n}/#{d}",
        ">"
      ])
    end
  end
end
