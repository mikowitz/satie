defmodule Satie.TimespanList.ToLilypond do
  @moduledoc """
    Helper functions for converting a TimespanList to lilypond/postscript output
  """

  @spacer ""
  @for Satie.TimespanList

  alias Satie.Timespan

  import Satie.Lilypond.OutputHelpers

  def to_lilypond(%@for{timespans: timespans} = timespan_list, opts) do
    sorted_offsets =
      Enum.map(timespans, &Timespan.to_tuple_pair/1)
      |> List.flatten()
      |> Enum.sort_by(fn {n, d} -> n / d end)
      |> Enum.uniq()

    {{min_n, min_d}, {max_n, max_d}} =
      case Keyword.get(opts, :range, nil) do
        nil -> Enum.min_max(sorted_offsets)
        a..b -> {{a, 1}, {b, 1}}
      end

    min = min_n / min_d
    max = max_n / max_d

    mapper = mapper_between_ranges({min, max}, {1, 106})

    indexed_sublists =
      timespan_list
      |> @for.explode()
      |> Enum.map(& &1.timespans)
      |> Enum.with_index()

    output_rows =
      indexed_sublists
      |> Enum.map_join("\n\n", fn {sublist, index} ->
        generate_output_row(sublist, index, mapper)
      end)

    output_dashes =
      indexed_sublists
      |> Enum.drop(1)
      |> Enum.map_join("\n\n", &generate_output_dashes(&1, mapper))

    [
      "\\markup \\column {",
      build_labels(sorted_offsets, mapper),
      build_postscript(output_rows, output_dashes),
      "}"
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp build_postscript(rows, dashes) do
    [
      "  \\postscript #\"",
      "  0.2 setlinewidth",
      @spacer,
      rows,
      build_dashes(dashes),
      "  \""
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp build_dashes(""), do: nil

  defp build_dashes(dashes) do
    [
      @spacer,
      "  0.1 setlinewidth",
      "  [ 0.4 0.4 ] 0 setdash",
      @spacer,
      dashes
    ]
  end

  defp build_labels(offsets, mapper) do
    [
      "\\overlay {",
      generate_offset_labels(offsets, mapper),
      "}"
    ]
    |> indent()
  end

  defp generate_offset_labels(offsets, mapper) do
    Enum.map_join(offsets, "\n", fn {n, d} ->
      x = mapper.(n / d)

      [
        "\\translate #'(#{x} . 1)",
        "\\fontsize #-2 \\center-align \\fraction #{n} #{d}"
      ]
      |> indent()
      |> Enum.join("\n")
    end)
  end

  defp generate_output_row(timespans, index, mapper) do
    y = 1 - 3 * index

    timespans
    |> Enum.map(&Timespan.to_tuple_pair/1)
    |> Enum.map_join("\n", fn [{start_n, start_d}, {stop_n, stop_d}] ->
      start_x = mapper.(start_n / start_d)
      stop_x = mapper.(stop_n / stop_d)

      [
        {start_x, y - 0.5, start_x, y + 0.5},
        {stop_x, y - 0.5, stop_x, y + 0.5},
        {start_x, y / 1, stop_x, y / 1}
      ]
      |> Enum.map_join("\n", &draw_line/1)
    end)
  end

  defp generate_output_dashes({timespans, index}, mapper) do
    y = 2 - 3 * index

    timespans
    |> Enum.map(&Timespan.to_tuple_pair/1)
    |> List.flatten()
    |> Enum.map_join("\n", fn {n, d} ->
      x = mapper.(n / d)

      draw_line({x, 2.0, x, y / 1})
    end)
  end

  defp draw_line({x1, y1, x2, y2}) do
    """
    #{x1} #{y1} moveto
    #{x2} #{y2} lineto
    stroke
    """
    |> String.trim_trailing()
    |> indent()
  end

  defp mapper_between_ranges({in_start, in_stop}, {out_start, out_stop}) do
    fn input ->
      (out_start + (out_stop - out_start) / (in_stop - in_start) * (input - in_start))
      |> Float.round(2)
    end
  end
end
