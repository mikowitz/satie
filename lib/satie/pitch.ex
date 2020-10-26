defmodule Satie.Pitch do
  defstruct [:pitch_class_index, :octave]

  @doc """

    iex> Pitch.new(1,4)
    %Pitch{
      pitch_class_index: 1,
      octave: 4
    }

    iex> Pitch.new(17, 3)
    %Pitch{
      pitch_class_index: 5,
      octave: 3
    }

  """
  def new(pitch_class_index \\ 0, octave \\ 4) do
    with pci <- Integer.mod(pitch_class_index, 12) do
      %__MODULE__{
        pitch_class_index: pci,
        octave: octave
      }
    end
  end
end

defimpl Satie.ToLilypond, for: Satie.Pitch do
  @pitches ~w(c cs d ef e f fs g af a bf b)

  def to_lilypond(%Satie.Pitch{pitch_class_index: pci, octave: o}) do
    pitch_class_string(pci) <> octave_string(o)
  end

  ## PRIVATE

  defp pitch_class_string(pitch_class_index) do
    Enum.at(@pitches, pitch_class_index)
  end

  defp octave_string(3), do: ""
  defp octave_string(o) when o < 3, do: String.duplicate(",", 3 - o)
  defp octave_string(o) when o > 3, do: String.duplicate("'", o - 3)
end
