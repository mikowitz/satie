defmodule Satie.Fractional do
  @moduledoc """
  Implements shared functionality for fractional-types

    * `Satie.Duration`
    * `Satie.Multiplier`
    * `Satie.Offset`
    * `Satie.Fraction`

  """

  alias Satie.Offset

  def to_tuple(%{numerator: n, denominator: d}), do: {n, d}

  def __init__({n, d}, mod) do
    {n, d}
    |> reduce()
    |> then(fn {n, d} -> struct(mod, %{numerator: n, denominator: d}) end)
  end

  def reduce({a, b}) do
    with g <- Integer.gcd(a, b) do
      {round(a / g), round(b / g)}
      |> correct_polarity()
    end
  end

  def to_offset(%{numerator: n, denominator: d}), do: Offset.new(n, d)

  defp correct_polarity({a, b}) when b < 0, do: {a * -1, b * -1}
  defp correct_polarity({a, b}), do: {a, b}
end
