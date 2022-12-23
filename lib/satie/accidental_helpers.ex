defmodule Satie.AccidentalHelpers do
  @moduledoc """
  Helper functions for building `Satie.Accidental` structs
  """

  @name_to_semitones %{
    "ff" => -2.0,
    "tqf" => -1.5,
    "f" => -1.0,
    "qf" => -0.5,
    "natural" => 0.0,
    "qs" => 0.5,
    "s" => 1.0,
    "tqs" => 1.5,
    "ss" => 2.0
  }

  @semitones_to_name %{
    -2.0 => "ff",
    -1.5 => "tqf",
    -1.0 => "f",
    -0.5 => "qf",
    0.0 => "natural",
    0.5 => "qs",
    1.0 => "s",
    1.5 => "tqs",
    2.0 => "ss"
  }

  def correct_name(%{name: ""}), do: %{name: "natural"}
  def correct_name(%{name: "+"}), do: %{name: "qs"}
  def correct_name(%{name: "~"}), do: %{name: "qf"}
  def correct_name(%{name: "sqs"}), do: %{name: "tqs"}
  def correct_name(%{name: "fqf"}), do: %{name: "tqf"}
  def correct_name(map), do: map

  def calculate_semitones(%{name: name} = map) do
    semitones =
      case @name_to_semitones[name] do
        n when is_number(n) ->
          n

        nil ->
          Regex.scan(~r/q?[fs]/, name)
          |> List.flatten()
          |> Enum.map(fn n -> @name_to_semitones[n] end)
          |> Enum.sum()
      end

    Map.put_new(map, :semitones, semitones)
  end

  def semitones_to_name(semitones), do: @semitones_to_name[semitones]

  def calculate_quartertone(%{semitones: semitones} = map) do
    map
    |> Map.put(:full_semitones, floor(abs(semitones)))
    |> Map.put(:has_quartertone, :math.fmod(semitones, 1) != 0.0)
  end

  def calculate_accidental_char(%{semitones: semitones} = map) when semitones < 0,
    do: Map.put(map, :char, "f")

  def calculate_accidental_char(map), do: Map.put(map, :char, "s")

  def calculate_name(
        %{char: char, full_semitones: full_semitones, has_quartertone: has_quartertone} = map
      ) do
    name = String.duplicate(char, full_semitones)

    name_suffix = if has_quartertone, do: "q" <> char, else: ""

    Map.put(map, :name, name <> name_suffix)
  end
end
