defmodule Satie.TimespanList.Explode do
  @moduledoc """
    Helper functions for Satie.TimespanList.explode
  """

  alias Satie.{Timespan, TimespanList}

  def explode(%TimespanList{timespans: timespans} = timespan_list, list_count \\ nil)
      when is_nil(list_count) or is_integer(list_count) do
    global_timespan = TimespanList.timespan(timespan_list)

    timespans
    |> Enum.reduce([], fn timespan, results ->
      [non_overlapping_sets, overlapping_sets] =
        partition_by_overlapping(results, timespan, global_timespan)

      insert_timespan(timespan, non_overlapping_sets, overlapping_sets, results, list_count)
    end)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&TimespanList.new/1)
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
end
