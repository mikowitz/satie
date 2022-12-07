defmodule Satie.Timespan do
  @moduledoc """
    Models a closed-open timespan, with start and stop offsets
  """

  alias Satie.Offset

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
  def new(start_offset, stop_offset)
      when is_integer_duple_input(start_offset) and is_integer_duple_input(stop_offset) do
    %__MODULE__{
      start_offset: to_offset_duple(start_offset),
      stop_offset: to_offset_duple(stop_offset)
    }
  end

  @doc """

    iex> timespan = Timespan.new(1, 3)
    iex> Timespan.to_tuple_pair(timespan)
    [{1, 1}, {3, 1}]

  """
  def to_tuple_pair(%__MODULE__{start_offset: start_offset, stop_offset: stop_offset}) do
    Enum.map([start_offset, stop_offset], &Offset.to_tuple/1)
  end

  @doc """

      iex> timespan = Timespan.new(1, {25, 16})
      iex> Timespan.to_float_pair(timespan)
      [1.0, 1.5625]

  """
  def to_float_pair(%__MODULE__{start_offset: start_offset, stop_offset: stop_offset}) do
    Enum.map([start_offset, stop_offset], &Offset.to_float/1)
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
    def to_lilypond(%@for{} = timespan) do
      timespan
      |> List.wrap()
      |> Satie.TimespanList.new()
      |> Satie.to_lilypond()
    end
  end
end
