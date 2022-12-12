defmodule Satie.Offset do
  @moduledoc """
  Models a temporal offset as a rational fraction
  """

  import Satie.Guards

  defstruct [:numerator, :denominator]

  @doc """

      iex> Offset.new(0)
      #Satie.Offset<{0, 1}>

      iex> Offset.new(3, 16)
      #Satie.Offset<{3, 16}>

      iex> Offset.new({5, 18})
      #Satie.Offset<{5, 18}>

    Does not reduce fraction

      iex> Offset.new(4, 16)
      #Satie.Offset<{4, 16}>

  """
  def new({a, b} = offset) when is_integer_duple(offset), do: new(a, b)

  def new(numerator, denominator \\ 1) when is_integer(numerator) and is_integer(denominator) do
    %__MODULE__{numerator: numerator, denominator: denominator}
  end

  @doc """

    iex> offset = Offset.new(5, 16)
    iex> Offset.to_tuple(offset)
    {5, 16}

  """
  def to_tuple(%__MODULE__{numerator: n, denominator: d}) do
    {n, d}
  end

  @doc """

      iex> offset = Offset.new(7, 4)
      iex> Offset.to_float(offset)
      1.75

  """
  def to_float(%__MODULE__{numerator: n, denominator: d}), do: n / d

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

    def inspect(%@for{} = offset, _opts) do
      concat([
        "#Satie.Offset<",
        inspect(@for.to_tuple(offset)),
        ">"
      ])
    end
  end
end
