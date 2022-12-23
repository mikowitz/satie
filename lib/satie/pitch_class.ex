defmodule Satie.PitchClass do
  @moduledoc """
  Models a musical pitch class
  """
  defstruct [:name, :accidental, :semitones, :diatonic_pitch_class]

  alias Satie.Accidental

  def new(pitch_class), do: Satie.ToPitchClass.from(pitch_class)

  def new(diatonic_pitch_class, accidental), do: new({diatonic_pitch_class, accidental})

  def alteration(%__MODULE__{accidental: %Accidental{semitones: semitones}}), do: semitones

  defimpl String.Chars do
    def to_string(%@for{name: name}), do: name
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = pitch_class, _opts) do
      concat([
        "#Satie.PitchClass<",
        to_string(pitch_class),
        ">"
      ])
    end
  end
end
