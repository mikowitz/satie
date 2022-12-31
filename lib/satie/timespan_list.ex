defmodule Satie.TimespanList do
  @moduledoc """
  Models a collection of `Satie.Timespan` structs
  """

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

  defdelegate explode(timespan_list), to: Satie.TimespanList.Explode
  defdelegate explode(timespan_list, list_count), to: Satie.TimespanList.Explode

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

  def split(%__MODULE__{} = timespan_list, offsets) when is_list(offsets) do
    with {:ok, offsets} <- validate_offsets(offsets) do
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
    end
  end

  def split(%__MODULE__{} = timespan_list, offset) do
    case Offset.new(offset) do
      %Offset{} = offset -> do_split(timespan_list, offset)
      _ -> {:error, :timespan_list_split_non_offset_equivalent, offset}
    end
  end

  defp do_split(%__MODULE__{} = timespan_list, offset) do
    {timespans_before, timespans_after} =
      Enum.reduce(
        timespan_list.timespans,
        {[], []},
        fn timespan, {timespans_before, timespans_after} ->
          cond do
            Offset.lt(timespan.stop_offset, offset) ->
              {[timespan | timespans_before], timespans_after}

            Offset.lt(offset, timespan.start_offset) ->
              {timespans_before, [timespan | timespans_after]}

            true ->
              %__MODULE__{timespans: [ts_before, ts_after]} = Timespan.split(timespan, offset)
              {[ts_before | timespans_before], [ts_after | timespans_after]}
          end
        end
      )

    [
      new(sort_timespans(timespans_before)),
      new(sort_timespans(timespans_after))
    ]
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

  defp validate_offsets(offsets) when is_list(offsets) do
    offsets = Enum.map(offsets, &Offset.new/1)

    case Enum.reject(offsets, &is_struct(&1, Offset)) do
      [] ->
        {:ok, offsets}

      invalid_offsets ->
        {:error, :timespan_list_split_non_offset_equivalent,
         Enum.map(invalid_offsets, &elem(&1, 2))}
    end
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

  defp translate_timespans(timespans, translation_distance) do
    Enum.map(timespans, &Timespan.translate(&1, translation_distance))
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
    defdelegate to_lilypond(timespan_list, opts), to: Satie.TimespanList.ToLilypond
  end
end
