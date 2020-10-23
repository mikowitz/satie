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
