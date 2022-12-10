defmodule Satie.MultiMeasureRest do
  @moduledoc """
  Models a multi-measure rest
  """
  defstruct [:time_signature, :measures]

  alias Satie.TimeSignature

  @re ~r/^(R1\s*\*\s*)?(?<time_signature>\d+\/\d+)\s*\*\s*(?<measures>\d+)$/

  def new(multi_measure_rest) when is_bitstring(multi_measure_rest) do
    case Regex.named_captures(@re, multi_measure_rest) do
      %{"time_signature" => time_sig, "measures" => measures} ->
        {measures, ""} = Integer.parse(measures)
        new(TimeSignature.new(time_sig), measures)

      nil ->
        {:error, :multi_measure_rest_new, multi_measure_rest}
    end
  end

  def new(%TimeSignature{} = time_signature, measures)
      when is_integer(measures) and measures > 0 do
    %__MODULE__{
      time_signature: time_signature,
      measures: measures
    }
  end

  def new(time_signature, measures),
    do: {:error, :multi_measure_rest_new, {time_signature, measures}}

  defimpl String.Chars do
    def to_string(%@for{} = multi_measure_rest), do: Satie.to_lilypond(multi_measure_rest)
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{time_signature: %{numerator: n, denominator: d}, measures: m}, _opts) do
      concat([
        "#Satie.MultiMeasureRest<",
        "#{n}/#{d} * #{m}",
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{time_signature: %{numerator: n, denominator: d}, measures: m}, _opts) do
      "R1 * #{n}/#{d} * #{m}"
    end
  end
end
