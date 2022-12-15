defmodule Satie.Timespan do
  @moduledoc """
    Models a closed-open timespan, with start and stop offsets
  """

  alias Satie.{Duration, Offset, Timespan, TimespanList}

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

    iex> timespan = Timespan.new(1, 3)
    iex> Timespan.to_tuple_pair(timespan)
    [{1, 1}, {3, 1}]

  """
  def to_tuple_pair(%__MODULE__{} = timespan) do
    timespan
    |> offsets()
    |> Enum.map(&Offset.to_tuple/1)
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

  """
  def duration(%__MODULE__{} = timespan) do
    [{start_n, start_d}, {stop_n, stop_d}] = to_tuple_pair(timespan)
    start = Duration.new(start_n, start_d)
    stop = Duration.new(stop_n, stop_d)
    Duration.subtract(stop, start)
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

  defp filter_bad_offsets(offsets) when is_list(offsets) do
    Enum.reject(offsets, fn offset ->
      is_integer_duple_input(offset) || is_struct(offset, Offset)
    end)
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
