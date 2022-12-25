defmodule Satie.StartHairpin do
  @moduledoc """
  Models the beginning of a hairpin
  """

  defstruct [:direction]

  use Satie.Attachable

  def new(direction) do
    with {:ok, direction} <- validate_direction(direction) do
      %__MODULE__{direction: direction}
    end
  end

  @valid_crescendos [:<, :crescendo, :cresc, "<", "crescendo", "cresc"]
  @valid_decrescendos [:>, :decrescendo, :decresc, ">", "decrescendo", "decresc"]

  defp validate_direction(cresc) when cresc in @valid_crescendos, do: {:ok, :crescendo}
  defp validate_direction(decresc) when decresc in @valid_decrescendos, do: {:ok, :decrescendo}
  defp validate_direction(x), do: {:error, :start_hairpin_new, x}

  defimpl String.Chars do
    def to_string(%@for{direction: :crescendo}), do: "\\<"
    def to_string(%@for{direction: :decrescendo}), do: "\\>"
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{direction: direction}, _) do
      concat([
        "#Satie.StartHairpin<",
        to_string(direction),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{direction: :crescendo}, _), do: "\\<"
    def to_lilypond(%@for{direction: :decrescendo}, _), do: "\\>"
  end
end
