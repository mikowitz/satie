defmodule Satie.Multiplier do
  @moduledoc """
  Models a multiplier as a rational fraction
  """
  defstruct [:numerator, :denominator]

  def new(numerator, denominator) when is_integer(numerator) and is_integer(denominator) do
    %__MODULE__{numerator: numerator, denominator: denominator}
  end

  def new(numerator, denominator) do
    {:error, :multiplier_new, {numerator, denominator}}
  end
end
