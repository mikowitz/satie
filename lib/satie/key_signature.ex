defmodule Satie.KeySignature do
  @moduledoc """
  Models a key signature
  """
  defstruct [:pitch_class, :mode]

  use Satie.Attachable, location: :before, priority: 1, has_direction: false

  alias Satie.PitchClass

  @doc """

      iex> KeySignature.new("e")
      #Satie.KeySignature<e major>

      iex> KeySignature.new("fqs", :minor)
      #Satie.KeySignature<fqs minor>

      iex> KeySignature.new("c", :whatever)
      {:error, :invalid_mode, :whatever}

  """
  def new(pitch_class, mode \\ :major) do
    with {:ok, pitch_class} <- validate_pitch_class(pitch_class),
         {:ok, mode} <- validate_mode(mode) do
      %__MODULE__{pitch_class: pitch_class, mode: mode}
    end
  end

  defp validate_pitch_class(pitch_class) do
    case PitchClass.new(pitch_class) do
      %PitchClass{} = pc -> {:ok, pc}
      error -> error
    end
  end

  @valid_modes ~w(major minor ionian dorian phrygian lydian mixolydian aeolian locrian)a
  defp validate_mode(mode) when mode in @valid_modes, do: {:ok, mode}
  defp validate_mode(mode), do: {:error, :invalid_mode, mode}

  defimpl String.Chars do
    def to_string(%@for{pitch_class: pitch_class, mode: mode}) do
      pitch_class.name <> " " <> Kernel.to_string(mode)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = key_signature, _opts) do
      concat([
        "#Satie.KeySignature<",
        to_string(key_signature),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{pitch_class: pitch_class, mode: mode}, _opts) do
      [
        "\\key",
        pitch_class.name,
        "\\#{mode}"
      ]
      |> Enum.join(" ")
    end
  end
end
