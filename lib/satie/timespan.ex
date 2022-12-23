defmodule Satie.Timespan do
  @moduledoc """
    Models a closed-open timespan, with start and stop offsets
  """

  alias Satie.{Duration, Offset, Timespan, TimespanList}
  alias Satie.Fractional

  import Satie.Guards

  defstruct [:start_offset, :stop_offset]

  @doc """

      iex> Timespan.new(0, 10)
      #Satie.Timespan<{0, 1}, {10, 1}>

      iex> Timespan.new({1,8}, {17,16})
      #Satie.Timespan<{1, 8}, {17, 16}>

      iex> Timespan.new(0, {17, 16})
      #Satie.Timespan<{0, 1}, {17, 16}>

      iex> Timespan.new({17, 16}, 2)
      #Satie.Timespan<{17, 16}, {2, 1}>

  """
  def new(%Offset{} = start_offset, %Offset{} = stop_offset) do
    %__MODULE__{
      start_offset: start_offset,
      stop_offset: stop_offset
    }
  end

  def new(start_offset, stop_offset)
      when is_integer_duple_input(start_offset) and is_integer_duple_input(stop_offset) do
    new(to_offset_duple(start_offset), to_offset_duple(stop_offset))
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> [start, stop] = Timespan.offsets(timespan)
      iex> start
      #Satie.Offset<{0, 1}>
      iex> stop
      #Satie.Offset<{10, 1}>

  """
  def offsets(%__MODULE__{start_offset: start_offset, stop_offset: stop_offset}) do
    [start_offset, stop_offset]
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.start_offset(timespan)
      #Satie.Offset<{0, 1}>

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.start_offset(timespan, Offset.new(3))
      #Satie.Timespan<{3, 1}, {10, 1}>

  """
  def start_offset(%__MODULE__{start_offset: start_offset} = timespan, new_offset \\ nil) do
    case new_offset do
      nil -> start_offset
      %Offset{} -> %{timespan | start_offset: new_offset}
    end
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.stop_offset(timespan)
      #Satie.Offset<{10, 1}>

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.stop_offset(timespan, Offset.new(3))
      #Satie.Timespan<{0, 1}, {3, 1}>

  """
  def stop_offset(%__MODULE__{stop_offset: stop_offset} = timespan, new_offset \\ nil) do
    case new_offset do
      nil -> stop_offset
      %Offset{} -> %{timespan | stop_offset: new_offset}
    end
  end

  @doc """

    iex> timespan = Timespan.new(1, 3)
    iex> Timespan.to_tuple_pair(timespan)
    [{1, 1}, {3, 1}]

  """
  def to_tuple_pair(%__MODULE__{} = timespan) do
    timespan
    |> offsets()
    |> Enum.map(&Fractional.to_tuple/1)
  end

  @doc """

      iex> timespan = Timespan.new(1, {25, 16})
      iex> Timespan.to_float_pair(timespan)
      [1.0, 1.5625]

  """
  def to_float_pair(%__MODULE__{} = timespan) do
    timespan
    |> offsets()
    |> Enum.map(&Offset.to_float/1)
  end

  @doc """

      iex> timespan = Timespan.new(1, {25, 16})
      iex> Timespan.length(timespan)
      0.5625

  """
  def length(%__MODULE__{} = timespan) do
    [a, b] = to_float_pair(timespan)
    b - a
  end

  @doc """

    iex> timespan1 = Timespan.new(1, 3)
    iex> timespan2 = Timespan.new(2, 4)
    iex> Timespan.overlap?(timespan1, timespan2)
    true
    iex> Timespan.overlap?(timespan2, timespan1)
    true

  """
  def overlap?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    [start1, stop1] = to_float_pair(timespan1)
    [start2, stop2] = to_float_pair(timespan2)

    between?(start1, {start2, stop2}) || between?(start2, {start1, stop1})
  end

  @doc """

    iex> timespan1 = Timespan.new(1, 3)
    iex> timespan2 = Timespan.new(3, 5)
    iex> Timespan.adjoin?(timespan1, timespan2)
    true
    iex> Timespan.adjoin?(timespan2, timespan1)
    true

  """
  def adjoin?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    [start1, stop1] = to_float_pair(timespan1)
    [start2, stop2] = to_float_pair(timespan2)

    start1 == stop2 || start2 == stop1
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.well_formed?(timespan)
      true

      iex> timespan = Timespan.new(10, 0)
      iex> Timespan.well_formed?(timespan)
      false

      iex> timespan = Timespan.new(0, 0)
      iex> Timespan.well_formed?(timespan)
      false

  """
  def well_formed?(%__MODULE__{start_offset: start_offset, stop_offset: stop_offset}) do
    Offset.lt(start_offset, stop_offset)
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.overlap_with(timespan, Timespan.new(5, 8))
      #Satie.Duration<breve.>
      iex> Timespan.overlap_with(timespan, Timespan.new(15, 28))
      #Satie.Duration<(0,1)>

  """
  def overlap_with(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    case intersection(timespan1, timespan2) do
      %{timespans: []} -> Duration.new(0, 1)
      %{timespans: [timespan]} -> duration(timespan)
    end
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.axis(timespan)
      #Satie.Offset<{5, 1}>

  """
  def axis(%__MODULE__{start_offset: start_offset, stop_offset: stop_offset}) do
    start_offset
    |> Offset.add(stop_offset)
    |> Offset.divide(2)
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.reflect(timespan)
      #Satie.Timespan<{0, 1}, {10, 1}>
      iex> Timespan.reflect(timespan, Offset.new(8))
      #Satie.Timespan<{6, 1}, {16, 1}>
      iex> Timespan.reflect(timespan, Offset.new(15))
      #Satie.Timespan<{20, 1}, {30, 1}>

  """
  def reflect(%__MODULE__{} = timespan, axis \\ nil) do
    axis = axis || axis(timespan)

    [start_offset, stop_offset] = offsets(timespan)

    pre_axis_duration = Offset.subtract(axis, start_offset)
    post_axis_duration = Offset.subtract(stop_offset, axis)

    new(Offset.subtract(axis, post_axis_duration), Offset.add(axis, pre_axis_duration))
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.translate(timespan, Offset.new(2))
      #Satie.Timespan<{2, 1}, {12, 1}>


      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.translate(timespan, [Offset.new(-2), Offset.new(3)])
      #Satie.Timespan<{-2, 1}, {13, 1}>

  """
  def translate(%__MODULE__{} = timespan, %Offset{} = translation_offset) do
    [start_offset, stop_offset] = offsets(timespan)

    new(
      Offset.add(start_offset, translation_offset),
      Offset.add(stop_offset, translation_offset)
    )
  end

  def translate(%__MODULE__{} = timespan, [
        %Offset{} = start_translation,
        %Offset{} = stop_translation
      ]) do
    [start_offset, stop_offset] = offsets(timespan)

    new(
      Offset.add(start_offset, start_translation),
      Offset.add(stop_offset, stop_translation)
    )
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.scale(timespan, 3)
      #Satie.Timespan<{0, 1}, {30, 1}>

      iex> timespan = Timespan.new(1, 10)
      iex> Timespan.scale(timespan, 3)
      #Satie.Timespan<{1, 1}, {28, 1}>

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.scale(timespan, 2, anchor: :right)
      #Satie.Timespan<{-10, 1}, {10, 1}>

  """
  def scale(%__MODULE__{} = timespan, factor, options \\ []) when is_integer(factor) do
    [start_offset, stop_offset] = offsets(timespan)
    length = Offset.subtract(stop_offset, start_offset)

    anchor = Keyword.get(options, :anchor, :left)

    scaled_length = Duration.multiply(length, factor)

    [new_start, new_stop] =
      case anchor do
        :left ->
          [start_offset, Offset.add(start_offset, scaled_length)]

        :right ->
          [Offset.subtract(stop_offset, scaled_length) |> Offset.new(), stop_offset]
      end

    new(new_start, new_stop)
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.stretch(timespan, 3)
      #Satie.Timespan<{0, 1}, {30, 1}>

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.stretch(timespan, 2, Offset.new(3, 1))
      #Satie.Timespan<{-3, 1}, {17, 1}>

  """
  def stretch(%__MODULE__{} = timespan, factor, anchor \\ nil) do
    anchor = anchor || timespan.start_offset

    [new_start_offset, new_stop_offset] =
      timespan
      |> offsets()
      |> Enum.map(fn offset ->
        Offset.subtract(offset, anchor)
        |> Duration.multiply(factor)
        |> Offset.new()
        |> Offset.add(anchor)
      end)

    new(new_start_offset, new_stop_offset)
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.union(timespan1, timespan2)
      #Satie.TimespanList<[
        Timespan({0, 1}, {8, 1})
      ]>

  """
  def union(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    if overlap?(timespan1, timespan2) || adjoin?(timespan1, timespan2) do
      {min, max} =
        [timespan1, timespan2]
        |> Enum.map(&to_tuple_pair/1)
        |> List.flatten()
        |> Enum.min_max_by(fn {n, d} -> n / d end)

      TimespanList.new([new(min, max)])
    else
      TimespanList.new([timespan1, timespan2])
    end
  end

  @doc """

      iex> timespan = Timespan.new(0, 4)
      iex> Timespan.repeat(timespan, 5)
      #Satie.TimespanList<[
        Timespan({0, 1}, {4, 1})
        Timespan({4, 1}, {8, 1})
        Timespan({8, 1}, {12, 1})
        Timespan({12, 1}, {16, 1})
        Timespan({16, 1}, {20, 1})
      ]>

      iex> timespan = Timespan.new(0, 4)
      iex> Timespan.repeat(timespan, 5, Offset.new(1))
      #Satie.TimespanList<[
        Timespan({0, 1}, {4, 1})
        Timespan({5, 1}, {9, 1})
        Timespan({10, 1}, {14, 1})
        Timespan({15, 1}, {19, 1})
        Timespan({20, 1}, {24, 1})
      ]>


      iex> timespan = Timespan.new(0, 4)
      iex> Timespan.repeat(timespan, 5, Offset.new(-2))
      #Satie.TimespanList<[
        Timespan({0, 1}, {4, 1})
        Timespan({2, 1}, {6, 1})
        Timespan({4, 1}, {8, 1})
        Timespan({6, 1}, {10, 1})
        Timespan({8, 1}, {12, 1})
      ]>

      iex> timespan = Timespan.new(-2, 3)
      iex> Timespan.repeat(timespan, 3)
      #Satie.TimespanList<[
        Timespan({-2, 1}, {3, 1})
        Timespan({3, 1}, {8, 1})
        Timespan({8, 1}, {13, 1})
      ]>

  """
  def repeat(%__MODULE__{} = timespan, count, spacer \\ Offset.new(0)) do
    duration = duration(timespan) |> Offset.new()
    translation_distance = Offset.add(duration, spacer)

    Enum.map(1..count, fn factor ->
      translate(timespan, Offset.multiply(translation_distance, factor - 1))
    end)
    |> Enum.sort_by(&to_float_pair/1)
    |> TimespanList.new()
  end

  @doc """

      iex> timespan = Timespan.new(0, 4)
      iex> Timespan.repeat_until(timespan, Offset.new(16))
      #Satie.TimespanList<[
        Timespan({0, 1}, {4, 1})
        Timespan({4, 1}, {8, 1})
        Timespan({8, 1}, {12, 1})
        Timespan({12, 1}, {16, 1})
      ]>

      iex> timespan = Timespan.new(0, 4)
      iex> Timespan.repeat_until(timespan, Offset.new(20), Offset.new(1))
      #Satie.TimespanList<[
        Timespan({0, 1}, {4, 1})
        Timespan({5, 1}, {9, 1})
        Timespan({10, 1}, {14, 1})
        Timespan({15, 1}, {19, 1})
      ]>


      iex> timespan = Timespan.new(0, 4)
      iex> Timespan.repeat_until(timespan, Offset.new(11), Offset.new(-2))
      #Satie.TimespanList<[
        Timespan({0, 1}, {4, 1})
        Timespan({2, 1}, {6, 1})
        Timespan({4, 1}, {8, 1})
        Timespan({6, 1}, {10, 1})
        Timespan({8, 1}, {11, 1})
      ]>

      iex> timespan = Timespan.new(-2, 4)
      iex> Timespan.repeat_until(timespan, Offset.new(11))
      #Satie.TimespanList<[
        Timespan({-2, 1}, {4, 1})
        Timespan({4, 1}, {10, 1})
        Timespan({10, 1}, {11, 1})
      ]>
  """
  def repeat_until(%__MODULE__{} = timespan, limit, spacer \\ Offset.new(0)) do
    duration = duration(timespan) |> Offset.new()
    translation_distance = Offset.add(duration, spacer)

    do_repeat_until([timespan], limit, translation_distance)
    |> Enum.filter(&well_formed?/1)
    |> Enum.sort_by(&to_float_pair/1)
    |> TimespanList.new()
  end

  defp do_repeat_until([last_timespan | _] = acc, limit, translation_distance) do
    new_timespan = translate(last_timespan, translation_distance)

    case Offset.gt(new_timespan.stop_offset, limit) do
      true -> [Timespan.stop_offset(new_timespan, limit) | acc]
      false -> do_repeat_until([new_timespan | acc], limit, translation_distance)
    end
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.intersection(timespan1, timespan2)
      #Satie.TimespanList<[
        Timespan({4, 1}, {5, 1})
      ]>

  """
  def intersection(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    case overlap?(timespan1, timespan2) do
      false ->
        TimespanList.new([])

      true ->
        [_, min, max, _] =
          [timespan1, timespan2]
          |> Enum.map(&to_tuple_pair/1)
          |> List.flatten()
          |> Enum.sort_by(fn {n, d} -> n / d end)

        TimespanList.new([new(min, max)])
    end
  end

  @doc """

      iex> timespan = Timespan.new({1,2}, {7,8})
      iex> Timespan.duration(timespan)
      #Satie.Duration<4.>

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.duration(timespan, Duration.new(3, 1))
      #Satie.Timespan<{0, 1}, {3, 1}>

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.duration(timespan, Duration.new(3, 1), anchor: :stop)
      #Satie.Timespan<{7, 1}, {10, 1}>

  """
  def duration(timespan, new_duration \\ nil, options \\ [])

  def duration(%__MODULE__{} = timespan, nil, []) do
    [{start_n, start_d}, {stop_n, stop_d}] = to_tuple_pair(timespan)
    start = Duration.new(start_n, start_d)
    stop = Duration.new(stop_n, stop_d)
    Duration.subtract(stop, start)
  end

  def duration(%__MODULE__{} = timespan, %Duration{} = new_duration, opts) do
    [start_offset, stop_offset] =
      case Keyword.get(opts, :anchor, :start) do
        :start ->
          [timespan.start_offset, Offset.add(timespan.start_offset, new_duration)]

        :stop ->
          [
            Offset.subtract(timespan.stop_offset, new_duration) |> Offset.new(),
            timespan.stop_offset
          ]
      end

    new(start_offset, stop_offset)
  end

  def split(%__MODULE__{} = timespan, %Offset{} = offset) do
    if Offset.lt(timespan.start_offset, offset) && Offset.lt(offset, timespan.stop_offset) do
      TimespanList.new([
        Timespan.new(timespan.start_offset, offset),
        Timespan.new(offset, timespan.stop_offset)
      ])
    else
      TimespanList.new([timespan])
    end
  end

  def split(%__MODULE__{} = timespan, offset) when is_integer_duple_input(offset) do
    split(timespan, Offset.new(offset))
  end

  def split(%__MODULE__{} = timespan, offsets) when is_list(offsets) do
    case filter_bad_offsets(offsets) do
      [] ->
        offsets
        |> Enum.map(&Offset.new/1)
        |> Enum.reduce([timespan], fn offset, timespans ->
          Enum.map(timespans, &split(&1, offset))
          |> Enum.map(& &1.timespans)
          |> List.flatten()
        end)
        |> TimespanList.new()

      bad_offsets ->
        {:error, :timespan_split_non_offset_equivalent, bad_offsets}
    end
  end

  def split(%__MODULE__{}, offset) do
    {:error, :timespan_split_non_offset_equivalent, offset}
  end

  @doc """

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.split_by_ratio(timespan, [1, 1, 1])
      #Satie.TimespanList<[
        Timespan({0, 1}, {10, 3})
        Timespan({10, 3}, {20, 3})
        Timespan({20, 3}, {10, 1})
      ]>

      iex> timespan = Timespan.new(0, 10)
      iex> Timespan.split_by_ratio(timespan, [1, 2, 1])
      #Satie.TimespanList<[
        Timespan({0, 1}, {5, 2})
        Timespan({5, 2}, {15, 2})
        Timespan({15, 2}, {10, 1})
      ]>

  """
  def split_by_ratio(%__MODULE__{} = timespan, ratio) when is_list(ratio) do
    duration = duration(timespan)
    parts = Enum.sum(ratio)
    smallest_duration = Duration.divide(duration, parts)

    Enum.map(ratio, &Duration.multiply(smallest_duration, &1))
    |> Enum.scan(&Duration.add/2)
    |> Enum.map(&Offset.new/1)
    |> List.insert_at(0, timespan.start_offset)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [n, d] -> new(n, d) end)
    |> TimespanList.new()
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.difference(timespan1, timespan2)
      #Satie.TimespanList<[
        Timespan({0, 1}, {4, 1})
      ]>

  """
  def difference(%__MODULE__{} = timespan, %__MODULE__{} = timespan) do
    TimespanList.new([])
  end

  def difference(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    cond do
      !overlap?(timespan1, timespan2) ->
        TimespanList.new([timespan1])

      contains?(timespan1, timespan2) ->
        TimespanList.new([
          new(timespan1.start_offset, timespan2.start_offset),
          new(timespan2.stop_offset, timespan1.stop_offset)
        ])

      contains?(timespan2, timespan1) ->
        TimespanList.new([])

      starts_within?(timespan2, timespan1) ->
        TimespanList.new([new(timespan1.start_offset, timespan2.start_offset)])

      stops_within?(timespan2, timespan1) ->
        TimespanList.new([new(timespan2.stop_offset, timespan1.stop_offset)])

      starts_with?(timespan1, timespan2) ->
        [start, stop] =
          Enum.sort_by([timespan1.stop_offset, timespan2.stop_offset], &Offset.to_float/1)

        TimespanList.new([new(start, stop)])

      stops_with?(timespan1, timespan2) ->
        [start, stop] =
          Enum.sort_by([timespan1.start_offset, timespan2.start_offset], &Offset.to_float/1)

        TimespanList.new([new(start, stop)])
    end
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 10)
      iex> timespan2 = Timespan.new(5, 15)
      iex> Timespan.xor(timespan1, timespan2)
      #Satie.TimespanList<[
        Timespan({0, 1}, {5, 1})
        Timespan({10, 1}, {15, 1})
      ]>

  """
  def xor(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    if !overlap?(timespan1, timespan2) || adjoin?(timespan1, timespan2) do
      [timespan1, timespan2]
      |> Enum.sort_by(&to_float_pair/1)
      |> TimespanList.new()
    else
      [start_offset1, stop_offset1] = offsets(timespan1)
      [start_offset2, stop_offset2] = offsets(timespan2)

      [start_offset1, start_offset2] =
        [start_offset1, start_offset2] |> Enum.sort_by(&Offset.to_float/1)

      [stop_offset1, stop_offset2] =
        [stop_offset1, stop_offset2] |> Enum.sort_by(&Offset.to_float/1)

      [
        Timespan.new(start_offset1, start_offset2),
        Timespan.new(stop_offset1, stop_offset2)
      ]
      |> Enum.filter(&well_formed?/1)
      |> Enum.sort_by(&to_float_pair/1)
      |> TimespanList.new()
    end
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.starts_before?(timespan1, timespan2)
      true
      iex> Timespan.starts_before?(timespan2, timespan1)
      false

  """
  def starts_before?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    Offset.lt(timespan1.start_offset, timespan2.start_offset)
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.starts_with?(timespan1, timespan2)
      false

  """
  def starts_with?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    Offset.eq(timespan1.start_offset, timespan2.start_offset)
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.starts_within?(timespan1, timespan2)
      false
      iex> Timespan.starts_within?(timespan2, timespan1)
      true

  """
  def starts_within?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    Offset.gt(timespan1.start_offset, timespan2.start_offset) &&
      Offset.lt(timespan1.start_offset, timespan2.stop_offset)
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.stops_before?(timespan1, timespan2)
      true
      iex> Timespan.stops_before?(timespan2, timespan1)
      false

  """
  def stops_before?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    Offset.lt(timespan1.stop_offset, timespan2.stop_offset)
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.stops_with?(timespan1, timespan2)
      false

  """
  def stops_with?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    Offset.eq(timespan1.stop_offset, timespan2.stop_offset)
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.stops_within?(timespan1, timespan2)
      true
      iex> Timespan.stops_within?(timespan2, timespan1)
      false

  """
  def stops_within?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    Offset.gt(timespan1.stop_offset, timespan2.start_offset) &&
      Offset.lt(timespan1.stop_offset, timespan2.stop_offset)
  end

  @doc """

      iex> timespan1 = Timespan.new(0, 5)
      iex> timespan2 = Timespan.new(4, 8)
      iex> Timespan.contains?(timespan1, timespan2)
      false
      iex> Timespan.contains?(timespan2, timespan1)
      false

  """
  def contains?(%__MODULE__{} = timespan1, %__MODULE__{} = timespan2) do
    starts_within?(timespan2, timespan1) && stops_within?(timespan2, timespan1)
  end

  defp between?(x, {a, b}), do: x >= a && x < b

  defp filter_bad_offsets(offsets) when is_list(offsets) do
    Enum.reject(offsets, fn offset ->
      is_integer_duple_input(offset) || is_struct(offset, Offset)
    end)
  end

  defp to_offset_duple(int) when is_integer(int), do: Offset.new(int)
  defp to_offset_duple({n, d} = duple) when is_integer_duple(duple), do: Offset.new(n, d)

  defimpl String.Chars do
    def to_string(%@for{} = timespan) do
      [start_tuple, stop_tuple] = @for.to_tuple_pair(timespan)
      "Timespan(#{inspect(start_tuple)}, #{inspect(stop_tuple)})"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = timespan, _opts) do
      [start, stop] = @for.to_tuple_pair(timespan)

      concat([
        "#Satie.Timespan<",
        inspect(start) <> ", ",
        inspect(stop),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = timespan, _opts) do
      timespan
      |> List.wrap()
      |> Satie.TimespanList.new()
      |> Satie.to_lilypond()
    end
  end
end
