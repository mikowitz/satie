defmodule Satie.Accidental do
  defstruct [:name, :semitones]

  import Satie.Helpers, only: [sign: 1]

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
        full_semitones = floor(abs(semitones))
        quarter = :math.fmod(semitones, 1) == 0.0

        char =
          case sign(semitones) do
            -1 -> "f"
            1 -> "s"
          end

        name = String.duplicate(char, full_semitones)

        name =
          case quarter do
            true -> name
            false -> name <> "q" <> char
          end

        %__MODULE__{name: name, semitones: semitones}
    end
  end

  defp correct_name(%{name: ""}), do: %{name: "natural"}
  defp correct_name(%{name: "+"}), do: %{name: "qs"}
  defp correct_name(%{name: "~"}), do: %{name: "qf"}
  defp correct_name(%{name: "sqs"}), do: %{name: "tqs"}
  defp correct_name(%{name: "fqf"}), do: %{name: "tqf"}
  defp correct_name(map), do: map

  defp calculate_semitones(%{name: name} = map) do
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
end
