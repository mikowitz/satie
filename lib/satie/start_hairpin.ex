defmodule Satie.StartHairpin do
  @moduledoc """
  Models the beginning of a hairpin
  """

  use Satie.Attachable, fields: [:direction, :output]

  def new(direction, opts \\ []) do
    output = Keyword.get(opts, :output, :symbol)

    with {:ok, direction} <- validate_direction(direction) do
      %__MODULE__{
        direction: direction,
        output: output,
        components: [after: [build_component(direction, output)]]
      }
    end
  end

  @valid_crescendos [:<, :crescendo, :cresc, "<", "crescendo", "cresc"]
  @valid_decrescendos [:>, :decrescendo, :decresc, ">", "decrescendo", "decresc"]

  defp validate_direction(cresc) when cresc in @valid_crescendos, do: {:ok, :crescendo}
  defp validate_direction(decresc) when decresc in @valid_decrescendos, do: {:ok, :decrescendo}
  defp validate_direction(x), do: {:error, :start_hairpin_new, x}

  defp build_component(:crescendo, :symbol), do: "\\<"
  defp build_component(:crescendo, :text), do: "\\cresc"
  defp build_component(:decrescendo, :symbol), do: "\\>"
  defp build_component(:decrescendo, :text), do: "\\decresc"

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
end
