defmodule Satie.Multiplier do
  @moduledoc """
  Models a multiplier as a rational fraction
  """
  defstruct [:numerator, :denominator]

  alias Satie.{Duration, Fraction}
  use Satie.Fractional
  import Satie.Guards

  def new(multiplier), do: Satie.ToMultiplier.from(multiplier)

  def new(numerator, denominator) do
    new({numerator, denominator})
  end

  def to_float(%__MODULE__{numerator: n, denominator: d}), do: n / d

  use Satie.Fractional.Math,
    add: [{Fraction, Fraction}],
    subtract: [{Fraction, Fraction}],
    multiply: [
      {Duration, Duration},
      {Fraction, Fraction}
    ],
    divide: [{Fraction, Fraction}]

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{numerator: n, denominator: d}, _) do
      concat([
        "#Satie.Multiplier<",
        "#{n}/#{d}",
        ">"
      ])
    end
  end
end
