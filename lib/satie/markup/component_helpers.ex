defmodule Satie.Markup.ComponentHelpers do
  @moduledoc """
    Helper functions to construct attachable components for markup structs
  """

  alias Satie.Markup

  import Satie.Lilypond.OutputHelpers

  def build_component(%Markup{} = markup) do
    component = do_build_component(markup)

    %Markup{markup | components: [after: [component]]}
  end

  defp do_build_component(%Markup{content: content}) when is_bitstring(content) do
    [
      "\\markup {",
      indent(content),
      "}"
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp do_build_component(%Markup{content: content}) do
    [
      "\\markup {",
      indent(do_build_component(content)),
      "}"
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp do_build_component(components) when is_list(components) do
    Enum.map_join(components, "\n", &do_build_component/1)
  end

  defp do_build_component(%{command: _, content: content} = map) do
    [
      build_overrides(map),
      build_command(map),
      indent(do_build_component(content)),
      "}"
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp do_build_component(%{command: _} = map) do
    [
      build_overrides(map),
      build_entity(map)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp do_build_component(content) when is_bitstring(content), do: inspect(content)

  defp build_command(%{} = map) do
    "#{build_entity(map)} {"
  end

  defp build_entity(%{command: command, arguments: arguments}) do
    arguments =
      arguments
      |> Enum.map_join(" ", &format_argument/1)

    "\\#{command} #{arguments}"
  end

  defp build_entity(%{command: command, argument: argument}) do
    "\\#{command} #{format_argument(argument)}"
  end

  defp build_entity(%{command: command}) do
    "\\#{command}"
  end

  defp format_argument(true), do: "##t"
  defp format_argument(false), do: "##f"
  defp format_argument(arg) when is_atom(arg), do: "##{to_string(arg)}"
  defp format_argument({a, b}), do: "#'(#{a} . #{b})"
  defp format_argument(%Satie.Duration{} = duration), do: "{#{Satie.to_lilypond(duration)}}"
  defp format_argument(%Satie.MultiMeasureRest{measures: measures}), do: "{1*#{measures}}"
  defp format_argument(%{command: _} = arg), do: do_build_component(arg)
  defp format_argument(arg), do: "##{inspect(arg)}"

  defp build_overrides(%{overrides: []}), do: nil

  defp build_overrides(%{overrides: overrides}) when is_map(overrides) do
    [
      "\\override #'(",
      Enum.map(overrides, fn {k, v} ->
        indent("(#{k} . #{v})")
      end),
      ")"
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp build_overrides(_), do: nil
end
