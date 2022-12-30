defmodule Satie.IntervalClass do
  @moduledoc """
  Models an interval class (P1-P8)
  """

  defstruct [:name, :size, :quality, :polarity]

  import Satie.Helpers, only: [normalize_size: 1]
  import Satie.IntervalHelpers

  alias Satie.Lilypond.Parser

  def new(interval_class) when is_bitstring(interval_class) do
    case Parser.interval().(interval_class) do
      {:ok, captures, ""} ->
        captures
        |> parse_polarity()
        |> parse_size()
        |> validate_quality(:interval_class)
        |> then(fn
          {:error, _, _} = error ->
            error

          %{} = map ->
            map
            |> correct_size_and_polarity()
            |> append_quartertone_to_quality()
            |> build_name()
            |> then(&struct(__MODULE__, &1))
        end)

      _ ->
        {:error, :interval_class_new, interval_class}
    end
  end

  defp correct_size_and_polarity(%{size: size, polarity: polarity} = map) do
    normal_size = normalize_size(size)

    {new_size, new_polarity} =
      case is_octave?(map, normal_size) do
        true ->
          cond do
            is_perfect?(map) -> {8, polarity}
            is_diminished_or_quarter_flat?(map) -> {normal_size, -polarity}
            true -> {normal_size, polarity}
          end

        false ->
          {normal_size, polarity}
      end

    {new_size, new_polarity} =
      case is_perfect_unison?(map) do
        true -> {new_size, 0}
        false -> {new_size * new_polarity, new_polarity}
      end

    %{map | size: new_size, polarity: new_polarity}
  end

  defimpl String.Chars do
    def to_string(%@for{name: name}), do: name
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = interval_class, _opts) do
      concat([
        "#Satie.IntervalClass<",
        to_string(interval_class),
        ">"
      ])
    end
  end
end
