defmodule Satie.Generators.Rhythm.IncisionRule do
  @moduledoc """
    Defines the incision rules for the ryhthm generator
  """
  defstruct suffix_counts: [0],
            suffix_talea: [0],
            suffix_denominator: 16,
            prefix_counts: [0],
            prefix_talea: [0],
            prefix_denominator: 16,
            outer_divisions_only: false

  def talea(%__MODULE__{} = rule, :prefix), do: prefix_talea(rule)
  def talea(%__MODULE__{} = rule, :suffix), do: suffix_talea(rule)

  defp prefix_talea(%__MODULE__{prefix_talea: numerators, prefix_denominator: denominator}) do
    numerators
    |> Enum.map(&Satie.Duration.new(&1, denominator))
    |> Satie.Talea.new()
  end

  defp suffix_talea(%__MODULE__{suffix_talea: numerators, suffix_denominator: denominator}) do
    numerators
    |> Enum.map(&Satie.Duration.new(&1, denominator))
    |> Satie.Talea.new()
  end
end
