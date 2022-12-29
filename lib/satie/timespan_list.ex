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

  @doc """

    iex> timespan_list = TimespanList.new([
    ...>   Timespan.new(-2, 5),
    ...>   Timespan.new(3, 6),
    ...>   Timespan.new(10, 15),
    ...> ])
    iex> [start, stop] = TimespanList.offsets(timespan_list)
    iex> start
    #Satie.Offset<-2/1>
    iex> stop
    #Satie.Offset<15/1>

  """
  def offsets(%__MODULE__{} = timespan_list) do
    timespan_list
    |> timespan()
    |> Timespan.offsets()
  end

  @doc """

    iex> timespan_list = TimespanList.new([
    ...>   Timespan.new(-2, 5),
    ...>   Timespan.new(3, 6),
    ...>   Timespan.new(10, 15),
    ...> ])
    iex> TimespanList.start_offset(timespan_list)
    #Satie.Offset<-2/1>

  """
  def start_offset(%__MODULE__{} = timespan_list) do
    timespan_list
    |> timespan()
    |> Timespan.start_offset()
  end

  @doc """

    iex> timespan_list = TimespanList.new([
    ...>   Timespan.new(-2, 5),
    ...>   Timespan.new(3, 6),
    ...>   Timespan.new(10, 15),
    ...> ])
    iex> TimespanList.stop_offset(timespan_list)
    #Satie.Offset<15/1>

  """
  def stop_offset(%__MODULE__{} = timespan_list) do
    timespan_list
    |> timespan()
    |> Timespan.stop_offset()
  end

  @doc """

    iex> timespan_list = TimespanList.new([
    ...>   Timespan.new(-2, 5),
    ...>   Timespan.new(3, 6),
    ...>   Timespan.new(10, 16),
    ...> ])
    iex> TimespanList.axis(timespan_list)
    #Satie.Offset<7/1>

  """
  def axis(%__MODULE__{} = timespan_list) do
    timespan_list
    |> timespan()
    |> Timespan.axis()
  end

  @doc """

    iex> timespan_list = TimespanList.new([
    ...>   Timespan.new(-2, 5),
    ...>   Timespan.new(3, 6),
    ...>   Timespan.new(10, 16),
    ...> ])
    iex> TimespanList.reflect(timespan_list)
    #Satie.TimespanList<[
      Timespan({-2, 1}, {4, 1})
      Timespan({8, 1}, {11, 1})
      Timespan({9, 1}, {16, 1})
    ]>

    iex> timespan_list = TimespanList.new([
    ...>   Timespan.new(-2, 5),
    ...>   Timespan.new(3, 6),
    ...>   Timespan.new(10, 16),
    ...> ])
    iex> TimespanList.reflect(timespan_list, Offset.new(0))
    #Satie.TimespanList<[
      Timespan({-16, 1}, {-10, 1})
      Timespan({-6, 1}, {-3, 1})
      Timespan({-5, 1}, {2, 1})
    ]>

  """
  def reflect(%__MODULE__{timespans: timespans} = timespan_list, axis \\ nil) do
    axis = axis || axis(timespan_list)

    timespans
    |> Enum.map(&Timespan.reflect(&1, axis))
    |> sort_timespans()
    |> new()
  end

  @doc """

      iex> timespan_list = TimespanList.new([
      ...>   Timespan.new(-2, 5),
      ...>   Timespan.new(3, 6),
      ...>   Timespan.new(10, 15),
      ...> ])
      iex> TimespanList.scale(timespan_list, 2)
      #Satie.TimespanList<[
        Timespan({-2, 1}, {12, 1})
        Timespan({3, 1}, {9, 1})
        Timespan({10, 1}, {20, 1})
      ]>

      iex> timespan_list = TimespanList.new([
      ...>   Timespan.new(-2, 5),
      ...>   Timespan.new(3, 6),
      ...>   Timespan.new(10, 15),
      ...> ])
      iex> TimespanList.scale(timespan_list, 2, anchor: :right)
      #Satie.TimespanList<[
        Timespan({-9, 1}, {5, 1})
        Timespan({0, 1}, {6, 1})
        Timespan({5, 1}, {15, 1})
      ]>

  """
  def scale(%__MODULE__{timespans: timespans}, factor, options \\ []) do
    timespans
    |> Enum.map(&Timespan.scale(&1, factor, options))
    |> sort_timespans()
    |> new()
  end

  @doc """

      iex> timespan_list = TimespanList.new([
      ...>   Timespan.new(-2, 5),
      ...>   Timespan.new(3, 6),
      ...>   Timespan.new(10, 15),
      ...> ])
      iex> TimespanList.stretch(timespan_list, 2)
      #Satie.TimespanList<[
        Timespan({-2, 1}, {12, 1})
        Timespan({8, 1}, {14, 1})
        Timespan({22, 1}, {32, 1})
      ]>

      iex> timespan_list = TimespanList.new([
      ...>   Timespan.new(-2, 5),
      ...>   Timespan.new(3, 6),
      ...>   Timespan.new(10, 15),
      ...> ])
      iex> TimespanList.stretch(timespan_list, 2, Offset.new(1))
      #Satie.TimespanList<[
        Timespan({-5, 1}, {9, 1})
        Timespan({5, 1}, {11, 1})
        Timespan({19, 1}, {29, 1})
      ]>

  """
  def stretch(%__MODULE__{timespans: timespans} = timespan_list, factor, anchor \\ nil) do
    anchor = anchor || start_offset(timespan_list)

    timespans
    |> Enum.map(&Timespan.stretch(&1, factor, anchor))
    |> sort_timespans()
    |> new()
  end

  @doc """

      iex> timespan_list = TimespanList.new([
      ...>   Timespan.new(-2, 5),
      ...>   Timespan.new(0, 10),
      ...>   Timespan.new(13, 15)
      ...> ])
      iex> TimespanList.translate(timespan_list, Offset.new(2))
      #Satie.TimespanList<[
        Timespan({0, 1}, {7, 1})
        Timespan({2, 1}, {12, 1})
        Timespan({15, 1}, {17, 1})
      ]>
      iex> TimespanList.translate(timespan_list, [Offset.new(-3), Offset.new(2)])
      #Satie.TimespanList<[
        Timespan({-5, 1}, {7, 1})
        Timespan({-3, 1}, {12, 1})
        Timespan({10, 1}, {17, 1})
      ]>

  """
  def translate(%__MODULE__{timespans: timespans}, %Offset{} = translation_offset) do
    timespans
    |> Enum.map(&Timespan.translate(&1, translation_offset))
    |> sort_timespans()
    |> new()
  end

  def translate(%__MODULE__{timespans: timespans}, offsets) when is_list(offsets) do
    timespans
    |> Enum.map(&Timespan.translate(&1, offsets))
    |> sort_timespans()
    |> new()
  end

  @doc """

      iex> timespan_list = TimespanList.new([
      ...>   Timespan.new(-2, 5),
      ...>   Timespan.new(3, 6),
      ...>   Timespan.new(10, 15),
      ...> ])
      iex> TimespanList.duration(timespan_list)
      #Satie.Duration<(17,1)>
  """
  def duration(%__MODULE__{} = timespan_list) do
    timespan_list
    |> timespan()
    |> Timespan.duration()
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

  def explode(%__MODULE__{timespans: timespans} = timespan_list, list_count \\ nil)
      when is_nil(list_count) or is_integer(list_count) do
    global_timespan = timespan(timespan_list)

    timespans
    |> Enum.reduce([], fn timespan, results ->
      [non_overlapping_sets, overlapping_sets] =
        partition_by_overlapping(results, timespan, global_timespan)

      insert_timespan(timespan, non_overlapping_sets, overlapping_sets, results, list_count)
    end)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&new/1)
  end

  defp insert_timespan(timespan, non_overlapping_sets, _overlapping_sets, results, nil) do
    case non_overlapping_sets do
      [] -> append_new_result(results, timespan)
      _ -> insert_into_lowest_overlap(non_overlapping_sets, results, timespan)
    end
  end

  defp insert_timespan(timespan, non_overlapping_sets, overlapping_sets, results, list_count) do
    case non_overlapping_sets do
      [] ->
        case length(results) < list_count do
          true -> append_new_result(results, timespan)
          false -> insert_into_lowest_overlap(overlapping_sets, results, timespan)
        end

      _ ->
        insert_into_lowest_overlap(non_overlapping_sets, results, timespan)
    end
  end

  defp insert_into_lowest_overlap(sets, results, timespan) do
    [{index, _, _, _} | _] = sets
    List.update_at(results, index, &[timespan | &1])
  end

  defp append_new_result(results, timespan), do: results ++ [[timespan]]

  defp partition_by_overlapping([], _timespan, _global_timespan), do: [[], []]

  defp partition_by_overlapping(timespan_sets, %Timespan{} = timespan, global_timespan) do
    grouped_sets =
      timespan_sets
      |> Enum.with_index()
      |> Enum.map(fn {set, index} ->
        {index, set, calculate_overlap_length(timespan, set),
         calculate_overlap_length(global_timespan, set)}
      end)
      |> Enum.group_by(fn {_, _, local_overlap, _} -> local_overlap > 0 end)

    [false, true]
    |> Enum.map(&Map.get(grouped_sets, &1, []))
    |> Enum.map(fn set ->
      Enum.sort_by(set, fn {_, _, local_overlap, global_overlap} ->
        [local_overlap, global_overlap]
      end)
    end)
  end

  defp calculate_overlap_length(%Timespan{} = timespan1, timespans) when is_list(timespans) do
    Enum.map(timespans, &calculate_overlap_length(&1, timespan1))
    |> Enum.sum()
  end

  defp calculate_overlap_length(%Timespan{} = timespan1, %Timespan{} = timespan2) do
    Timespan.intersection(timespan1, timespan2).timespans
    |> Enum.map(&Timespan.length/1)
    |> Enum.sum()
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

  @doc """

      iex> timespan_list = TimespanList.new([
      ...>   Timespan.new(-2, 5),
      ...>   Timespan.new(3, 6),
      ...>   Timespan.new(10, 15),
      ...> ])
      iex> TimespanList.repeat(timespan_list, 2)
      #Satie.TimespanList<[
        Timespan({-2, 1}, {5, 1})
        Timespan({3, 1}, {6, 1})
        Timespan({10, 1}, {15, 1})
        Timespan({15, 1}, {22, 1})
        Timespan({20, 1}, {23, 1})
        Timespan({27, 1}, {32, 1})
      ]>

  """
  def repeat(%__MODULE__{timespans: timespans} = timespan_list, count, spacer \\ Offset.new(0)) do
    duration = duration(timespan_list) |> Offset.new()
    translation_distance = Offset.add(duration, spacer)

    Enum.map(1..count, fn factor ->
      translate_timespans(timespans, Offset.multiply(translation_distance, factor - 1))
    end)
    |> List.flatten()
    |> sort_timespans()
    |> new()
  end

  defp translate_timespans(timespans, translation_distance) do
    Enum.map(timespans, &Timespan.translate(&1, translation_distance))
  end

  @doc """

      iex> timespan_list = TimespanList.new([
      ...>   Timespan.new(-2, 5),
      ...>   Timespan.new(3, 6),
      ...>   Timespan.new(10, 15),
      ...> ])
      iex> TimespanList.repeat_until(timespan_list, Offset.new(50))
      #Satie.TimespanList<[
        Timespan({-2, 1}, {5, 1})
        Timespan({3, 1}, {6, 1})
        Timespan({10, 1}, {15, 1})
        Timespan({15, 1}, {22, 1})
        Timespan({20, 1}, {23, 1})
        Timespan({27, 1}, {32, 1})
        Timespan({32, 1}, {39, 1})
        Timespan({37, 1}, {40, 1})
        Timespan({44, 1}, {49, 1})
        Timespan({49, 1}, {50, 1})
      ]>

  """
  def repeat_until(
        %__MODULE__{timespans: timespans} = timespan_list,
        limit,
        spacer \\ Offset.new(0)
      ) do
    duration = duration(timespan_list) |> Offset.new()
    translation_distance = Offset.add(duration, spacer)

    do_repeat_until([timespans], limit, translation_distance)
    |> List.flatten()
    |> Enum.filter(&Timespan.well_formed?/1)
    |> sort_timespans()
    |> new()
  end

  defp do_repeat_until([last_timespans | _] = acc, limit, translation_distance) do
    new_timespans = Enum.map(last_timespans, &Timespan.translate(&1, translation_distance))

    limit_hit = Enum.any?(new_timespans, &Offset.gt(&1.stop_offset, limit))

    case limit_hit do
      true ->
        new_timespans = Enum.map(new_timespans, &stop_timespan_at_limit(&1, limit))
        [new_timespans | acc]

      false ->
        do_repeat_until([new_timespans | acc], limit, translation_distance)
    end
  end

  defp stop_timespan_at_limit(timespan, limit) do
    case Offset.gt(timespan.stop_offset, limit) do
      true -> Timespan.stop_offset(timespan, limit)
      false -> timespan
    end
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
