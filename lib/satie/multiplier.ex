defmodule Satie.Multiplier do
  @moduledoc """
  Models a multiplier as a rational fraction
  """
  defstruct [:numerator, :denominator]

  alias Satie.Duration
  use Satie.Fractional
  import Satie.Guards

  def new(multiplier), do: Satie.ToMultiplier.from(multiplier)

  def new(numerator, denominator) do
    new({numerator, denominator})
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

  def multiply(%__MODULE__{} = duration, %rhs_struct{} = rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)

    case rhs_struct do
      Duration -> Duration.new(n1 * n2, d1 * d2)
      _ -> new(n1 * n2, d1 * d2)
    end
  end

  def multiply(%__MODULE__{} = duration, rhs) when is_integer(rhs) do
    {n, d} = Fractional.to_tuple(duration)
    new(n * rhs, d)
  end

  def divide(%__MODULE__{} = duration, rhs) when is_fractional(rhs) do
    {n1, d1} = Fractional.to_tuple(duration)
    {n2, d2} = Fractional.to_tuple(rhs)

    new(n1 * d2, n2 * d1)
  end

  def divide(%__MODULE__{} = duration, rhs) when is_integer(rhs) and rhs != 0 do
    {n, d} = Fractional.to_tuple(duration)
    new(n, d * rhs)
  end
end
