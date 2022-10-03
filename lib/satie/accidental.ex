defmodule Satie.Accidental do
  defstruct [:name, :semitones]

  import Satie.Helpers, only: [sign: 1]

  @names ~w(ff tqf f qf natural qs s tqs ss)
  @semitones Enum.map(-4..4, &(&1 / 2))

  @name_to_semitones Enum.zip(@names, @semitones) |> Enum.into(%{})
  @semitones_to_name Enum.zip(@semitones, @names) |> Enum.into(%{})

  @name_corrections %{
    "" => "natural",
    "+" => "qs",
    "~" => "qf",
    "sqs" => "tqs",
    "fqf" => "tqf"
  }

  @re ~r/^(t?q[sf]|s+(qs)?|f+(qf)?|\+|~)?$/

  def new(accidental) when is_bitstring(accidental) do
    case Regex.match?(@re, accidental) do
      false ->
        {:error, :accidental_new, accidental}

      true ->
        %{name: accidental}
        |> correct_name()
        |> calculate_semitones()
        |> then(&struct(__MODULE__, &1))
    end
  end

  def new(semitones) when is_number(semitones) do
    case @semitones_to_name[semitones / 1] do
      name when is_bitstring(name) ->
        %__MODULE__{name: name, semitones: semitones}

      nil ->
        %{semitones: semitones}
        |> calculate_name()
        |> then(&struct(__MODULE__, &1))
    end
  end

  defp correct_name(%{name: name}) do
    %{name: Map.get(@name_corrections, name, name)}
  end

  defp calculate_semitones(%{name: name} = map) do
    semitones =
      case @name_to_semitones[name] do
        n when is_number(n) -> n
        nil -> calculate_semitones_from_string(name)
      end

    Map.put_new(map, :semitones, semitones)
  end

  defp calculate_semitones_from_string(name) do
    Regex.scan(~r/q?[fs]/, name)
    |> List.flatten()
    |> Enum.map(fn n -> @name_to_semitones[n] end)
    |> Enum.sum()
  end

  defp calculate_name(%{semitones: semitones} = map) do
    name =
      accidental_char_from_semitones(semitones)
      |> build_name(semitones)

    Map.put_new(map, :name, name)
  end

  defp accidental_char_from_semitones(semitones) do
    case sign(semitones) do
      -1 -> "f"
      1 -> "s"
    end
  end

  defp build_name(char, semitones) do
    full_semitones = floor(abs(semitones))
    quarter = :math.fmod(semitones, 1) == 0.0
    name = String.duplicate(char, full_semitones)

    case quarter do
      true -> name
      false -> name <> "q" <> char
    end
  end
end
