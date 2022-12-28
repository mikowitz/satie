defmodule Satie.TimeSignature do
  @moduledoc """
  Models a time signature
  """

  # TODO: have this use a Fraction
  use Satie.Attachable,
    fields: [:numerator, :denominator],
    location: :before,
    priority: 3,
    has_direction: false

  @re ~r/^(\\time\s+)?(?<numerator>\d+)\/(?<denominator>\d+)$/

  def new(time_signature) when is_bitstring(time_signature) do
    case Regex.named_captures(@re, time_signature) do
      %{"numerator" => numerator, "denominator" => denominator} ->
        {n, ""} = Integer.parse(numerator)
        {d, ""} = Integer.parse(denominator)
        new(n, d)

      nil ->
        {:error, :time_signature_new, time_signature}
    end
  end

  def new(numerator, denominator) when is_integer(numerator) and is_integer(denominator) do
    %__MODULE__{
      numerator: numerator,
      denominator: denominator,
      components: [
        before: [
          "\\time #{numerator}/#{denominator}"
        ]
      ]
    }
  end

  def new(numerator, denominator), do: {:error, :time_signature_new, {numerator, denominator}}

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{numerator: n, denominator: d}, _opts) do
      concat([
        "#Satie.TimeSignature<",
        "#{n}/#{d}",
        ">"
      ])
    end
  end
end
