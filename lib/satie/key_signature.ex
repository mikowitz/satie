defmodule Satie.KeySignature do
  @moduledoc """
  Models a key signature
  """

  use Satie.Attachable,
    fields: [:pitch_class, :mode],
    location: :before,
    priority: 1,
    has_direction: false

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
    with {:ok, pc} <- validate_pitch_class(pitch_class),
         {:ok, mode} <- validate_mode(mode) do
      %__MODULE__{
        pitch_class: pc,
        mode: mode,
        components: [
          before: [
            "\\key #{pc.name} \\#{mode}"
          ]
        ]
      }
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

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{pitch_class: pc, mode: mode}, _opts) do
      concat([
        "#Satie.KeySignature<",
        "#{pc.name} #{mode}",
        ">"
      ])
    end
  end
end
