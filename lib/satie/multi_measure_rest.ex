defmodule Satie.MultiMeasureRest do
  @moduledoc """
  Models a multi-measure rest
  """
  defstruct [:multiplier, :measures]

  alias Satie.Multiplier

  @re ~r/^(R1\s*\*\s*)?(?<multiplier>\d+\/\d+)\s*\*\s*(?<measures>\d+)$/

  def new(multi_measure_rest) when is_bitstring(multi_measure_rest) do
    case Regex.named_captures(@re, multi_measure_rest) do
      %{"multiplier" => multiplier, "measures" => measures} ->
        {measures, ""} = Integer.parse(measures)
        new(Multiplier.new(multiplier), measures)

      nil ->
        {:error, :multi_measure_rest_new, multi_measure_rest}
    end
  end

  def new(multiplier, measures)
      when is_integer(measures) and measures > 0 do
    case Multiplier.new(multiplier) do
      %Multiplier{} = mult ->
        %__MODULE__{
          multiplier: mult,
          measures: measures
        }

      _ ->
        {:error, :multi_measure_rest_new, {multiplier, measures}}
    end
  end

  def new(multiplier, measures) do
    {:error, :multi_measure_rest_new, {multiplier, measures}}
  end

  defimpl String.Chars do
    def to_string(%@for{} = multi_measure_rest), do: Satie.to_lilypond(multi_measure_rest)
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{multiplier: mult, measures: m}, _opts) do
      {n, d} = Satie.Fraction.to_tuple(mult)

      concat([
        "#Satie.MultiMeasureRest<",
        "#{n}/#{d} * #{m}",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{multiplier: mult, measures: m}, _opts) do
      {n, d} = Satie.Fraction.to_tuple(mult)

      "R1 * #{n}/#{d} * #{m}"
    end
  end
end
