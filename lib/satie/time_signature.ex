defmodule Satie.TimeSignature do
  @moduledoc """
  Models a time signature
  """

  alias Satie.Fraction

  use Satie.Attachable,
    fields: [:fraction],
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
      fraction: Fraction.new(numerator, denominator),
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

    def inspect(%@for{fraction: fraction}, _opts) do
      {n, d} = Fraction.to_tuple(fraction)

      concat([
        "#Satie.TimeSignature<",
        "#{n}/#{d}",
        ">"
      ])
    end
  end
end
