defmodule Satie.Fraction do
  @moduledoc """
    Modules a non-reduced fraction.
  """

  defstruct [:numerator, :denominator]

  use Satie.Fractional, reduce: false
  use Satie.Fractional.Math

  def new(fraction), do: Satie.ToFraction.from(fraction)

  def new(numerator, denominator) do
    new({numerator, denominator})
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{numerator: n, denominator: d}, _) do
      concat([
        "#Satie.Fraction<",
        "#{n}/#{d}",
        ">"
      ])
    end
  end
end
