defmodule Satie.Arpeggio do
  @moduledoc """
    Models an arpeggio
  """

  use Satie.Attachable,
    fields: [:style],
    has_direction: false

  def new(style \\ :normal) do
    with {:ok, style} <- validate_style(style) do
      %__MODULE__{
        style: style,
        components: [
          before: [_style_component(style)],
          after: ["\\arpeggio"]
        ]
      }
    end
  end

  @valid_styles ~w(normal arrow_up arrow_down bracket parenthesis parenthesis_dashed)a
  defp validate_style(style) when style in @valid_styles, do: {:ok, style}

  defp validate_style(style) when is_bitstring(style) do
    style |> String.to_atom() |> validate_style()
  end

  defp validate_style(style), do: {:error, :arpeggio_new, style}

  def _style_component(style) do
    suffix = style |> to_string() |> Macro.camelize()
    "\\arpeggio#{suffix}"
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{style: style}, _) do
      concat([
        "#Satie.Arpeggio<",
        format_style(style),
        ">"
      ])
    end

    defp format_style(:normal), do: ""
    defp format_style(style), do: to_string(style)
  end
end
