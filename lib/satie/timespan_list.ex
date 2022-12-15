defmodule Satie.TimespanList do
  @moduledoc """
  Models a collection of `Satie.Timespan` structs
  """

  import Satie.Guards

  alias Satie.{Offset, Timespan}

  defstruct [:timespans]

  @doc """

      iex> TimespanList.new()
      #Satie.TimespanList<[]>

    iex> TimespanList.new([
    ...>   Timespan.new(0, 10),
    ...>   Timespan.new(2, 4)
    ...> ])
    #Satie.TimespanList<[
      Timespan({0, 1}, {10, 1})
      Timespan({2, 1}, {4, 1})
    ]>

  """
  def new(timespans \\ []) do
    case validate_timespans(timespans) do
      {:ok, timespans} ->
        %__MODULE__{timespans: timespans}

      {:error, invalid_timespans} ->
        {:error, :timespan_list_new, invalid_timespans}
    end
  end

  def sorted_into_non_overlapping_sublists(%__MODULE__{timespans: timespans}) do
    Enum.reduce(timespans, [[]], &insert_without_overlapping/2)
  end

  def well_formed?(%__MODULE__{timespans: timespans}) do
    Enum.all?(timespans, &Timespan.well_formed?/1)
  end

  def all_non_overlapping?(%__MODULE__{timespans: timespans}) do
    Enum.all?(timespans, fn timespan ->
      Enum.filter(timespans -- [timespan], fn timespan2 ->
        Timespan.overlap?(timespan, timespan2)
      end) == []
    end)
  end

  def contiguous?(%__MODULE__{timespans: timespans} = timespan_list) do
    all_non_overlapping?(timespan_list) &&
      Enum.all?(timespans, fn timespan ->
        Enum.any?(timespans -- [timespan], fn timespan2 ->
          Timespan.adjoin?(timespan, timespan2)
        end)
      end)
  end

  @doc """

    iex> timespan_list = TimespanList.new([
    ...>   Timespan.new(0, 3),
    ...>   Timespan.new(3, 6),
    ...>   Timespan.new(6, 10),
    ...> ])
    iex> TimespanList.timespan(timespan_list)
    #Satie.Timespan<{0, 1}, {10, 1}>

  """
  def timespan(%__MODULE__{timespans: []}), do: Timespan.new(0, 0)

  def timespan(%__MODULE__{timespans: timespans}) do
    [starts, stops] =
      timespans
      |> Enum.map(&Timespan.offsets/1)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)

    Timespan.new(
      Enum.min_by(starts, &Offset.to_float/1),
      Enum.max_by(stops, &Offset.to_float/1)
    )
  end

  def partition(timespan_list, options \\ [])
  def partition(%__MODULE__{timespans: []}, _options), do: []

  def partition(%__MODULE__{timespans: timespans}, options) do
    [timespan | timespans] =
      timespans
      |> sort_timespans()

    func =
      case Keyword.get(options, :include_adjoining, false) do
        false -> &Timespan.overlap?(&1, &2)
        true -> fn ts1, ts2 -> Timespan.overlap?(ts1, ts2) || Timespan.adjoin?(ts1, ts2) end
      end

    do_partition(timespans, [[timespan]], func)
  end

  def intersection(%__MODULE__{timespans: timespans}, %Timespan{} = operand) do
    Enum.map(timespans, &Timespan.intersection(&1, operand))
    |> Enum.map(& &1.timespans)
    |> List.flatten()
    |> new()
  end

  def difference(%__MODULE__{timespans: timespans}, %Timespan{} = operand) do
    Enum.map(timespans, &Timespan.difference(&1, operand))
    |> Enum.map(& &1.timespans)
    |> List.flatten()
    |> new()
  end

  def split(%__MODULE__{} = timespan_list, %Offset{} = offset) do
    {timespans_before, timespans_after} =
      Enum.reduce(timespan_list.timespans, {[], []}, fn timespan,
                                                        {timespans_before, timespans_after} ->
        cond do
          Offset.lt(timespan.stop_offset, offset) ->
            {[timespan | timespans_before], timespans_after}

          Offset.lt(offset, timespan.start_offset) ->
            {timespans_before, [timespan | timespans_after]}

          true ->
            %__MODULE__{timespans: [ts_before, ts_after]} = Timespan.split(timespan, offset)
            {[ts_before | timespans_before], [ts_after | timespans_after]}
        end
      end)

    [
      new(sort_timespans(timespans_before)),
      new(sort_timespans(timespans_after))
    ]
  end

  def split(%__MODULE__{} = timespan_list, offset) when is_integer_duple_input(offset) do
    split(timespan_list, Offset.new(offset))
  end

  def split(%__MODULE__{} = timespan_list, offsets) when is_list(offsets) do
    case filter_bad_offsets(offsets) do
      [] ->
        offsets
        |> Enum.map(&Offset.new/1)
        |> Enum.sort_by(&Offset.to_float/1)
        |> Enum.reduce([timespan_list], fn offset, acc ->
          timespan_list = List.last(acc)
          new_timespan_lists = split(timespan_list, offset)

          acc
          |> List.replace_at(-1, new_timespan_lists)
          |> List.flatten()
        end)

      bad_offsets ->
        {:error, :timespan_list_split_non_offset_equivalent, bad_offsets}
    end
  end

  def split(%__MODULE__{}, offset) do
    {:error, :timespan_list_split_non_offset_equivalent, offset}
  end

  def union(%__MODULE__{timespans: []} = timespan_list), do: timespan_list

  def union(%__MODULE__{timespans: [timespan | timespans]}) do
    Enum.reduce(timespans, [timespan], fn timespan, [timespan2 | acc] ->
      %__MODULE__{timespans: timespans} = Timespan.union(timespan, timespan2)
      Enum.uniq(timespans ++ acc)
    end)
    |> Enum.sort_by(&Timespan.to_float_pair/1)
    |> new()
  end

  def intersection(%__MODULE__{timespans: []} = timespan_list), do: timespan_list

  def intersection(%__MODULE__{timespans: [timespan | timespans]}) do
    Enum.reduce_while(timespans, timespan, fn timespan, timespan2 ->
      %__MODULE__{timespans: timespans} = Timespan.intersection(timespan, timespan2)

      case timespans do
        [timespan | _] -> {:cont, timespan}
        [] -> {:halt, nil}
      end
    end)
    |> List.wrap()
    |> new()
  end

  def xor(%__MODULE__{timespans: []}), do: new([])

  def xor(%__MODULE__{timespans: timespans}) do
    Enum.map(timespans, fn timespan1 ->
      calc_fragments(timespan1, timespans)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(&Timespan.well_formed?/1)
    |> Enum.sort_by(&Timespan.to_float_pair/1)
    |> new()
  end

  defp calc_revised_fragments(fragments, timespan) do
    Enum.map(fragments, fn fragment ->
      case Timespan.overlap?(timespan, fragment) do
        true -> Timespan.difference(fragment, timespan).timespans
        false -> fragment
      end
    end)
    |> List.flatten()
  end

  defp calc_fragments(timespan1, timespans) do
    timespan1_fragments = [timespan1]

    Enum.reduce(timespans, timespan1_fragments, fn timespan2, fragments ->
      case timespan1 == timespan2 do
        true -> fragments
        false -> calc_revised_fragments(fragments, timespan2)
      end
    end)
  end

  defp filter_bad_offsets(offsets) when is_list(offsets) do
    Enum.reject(offsets, fn offset ->
      is_integer_duple_input(offset) || is_struct(offset, Offset)
    end)
  end

  defp insert_without_overlapping(timespan, sublists) do
    case Enum.find_index(sublists, &no_overlap?(&1, timespan)) do
      nil -> sublists ++ [[timespan]]
      index -> List.update_at(sublists, index, &(&1 ++ [timespan]))
    end
  end

  defp no_overlap?(list, timespan) do
    !Enum.any?(list, &Timespan.overlap?(timespan, &1))
  end

  defp validate_timespans(timespans) when is_list(timespans) do
    case Enum.reject(timespans, &is_struct(&1, Satie.Timespan)) do
      [] -> {:ok, timespans}
      invalid_timespans -> {:error, invalid_timespans}
    end
  end

  defp sort_timespans(timespans) do
    Enum.sort_by(timespans, &Timespan.to_float_pair/1)
  end

  defp do_partition([], acc, _func) do
    acc
    |> Enum.reverse()
    |> Enum.map(fn timespans ->
      timespans
      |> sort_timespans()
      |> new()
    end)
  end

  defp do_partition([timespan | rest], [current | acc], func) do
    new_acc =
      case Enum.any?(current, &func.(timespan, &1)) do
        true -> [[timespan | current] | acc]
        false -> [[timespan], current | acc]
      end

    do_partition(rest, new_acc, func)
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{timespans: timespans}, _opts) do
      concat([
        "#Satie.TimespanList<[",
        inspect_timespans(timespans),
        "]>"
      ])
    end

    defp inspect_timespans([]), do: ""

    defp inspect_timespans(timespans) do
      timespans =
        timespans
        |> Enum.map_join("\n", &"  #{to_string(&1)}")

      "\n" <> timespans <> "\n"
    end
  end

  defimpl Satie.ToLilypond do
    @spacer ""

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
        @for.sorted_into_non_overlapping_sublists(timespan_list)
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
end
