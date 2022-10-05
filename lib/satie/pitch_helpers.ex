defmodule Satie.PitchHelpers do
  @diatonic_pitch_classes ~w(c d e f g a b)
  @semitones [0, 2, 4, 5, 7, 9, 11]
  @staff_spaces 0..6

  @dpc_to_semitones Enum.zip(@diatonic_pitch_classes, @semitones) |> Enum.into(%{})
  @dpc_to_staff_spaces Enum.zip(@diatonic_pitch_classes, @staff_spaces) |> Enum.into(%{})
  @staff_spaces_to_dpc Enum.zip(@staff_spaces, @diatonic_pitch_classes) |> Enum.into(%{})

  @semitones_to_quality_and_diatonic_number %{
    0 => {"P", 1},
    1 => {"m", 2},
    2 => {"M", 2},
    3 => {"m", 3},
    4 => {"M", 3},
    5 => {"P", 4},
    6 => {"d", 5},
    7 => {"P", 5},
    8 => {"m", 6},
    9 => {"M", 6},
    10 => {"m", 7},
    11 => {"M", 7},
    12 => {"P", 8}
  }

  @diatonic_number_to_quality_dictionary %{
    1 => %{"d" => -1, "P" => 0, "A" => 1},
    2 => %{"d" => 0, "m" => 1, "M" => 2, "A" => 3},
    3 => %{"d" => 2, "m" => 3, "M" => 4, "A" => 5},
    4 => %{"d" => 4, "P" => 5, "A" => 6},
    5 => %{"d" => 6, "P" => 7, "A" => 8},
    6 => %{"d" => 7, "m" => 8, "M" => 9, "A" => 10},
    7 => %{"d" => 9, "m" => 10, "M" => 11, "A" => 12},
    8 => %{"d" => 11, "P" => 12, "A" => 13}
  }

  def dpc_to_semitones(diatonic_pitch_class) do
    @dpc_to_semitones[diatonic_pitch_class]
  end

  def dpc_to_staff_spaces(diatonic_pitch_class) do
    @dpc_to_staff_spaces[diatonic_pitch_class]
  end

  def staff_spaces_to_dpc(staff_spaces) do
    @staff_spaces_to_dpc[staff_spaces]
  end

  def semitones_to_quality_and_diatonic_number(semitones) do
    @semitones_to_quality_and_diatonic_number[semitones]
  end

  def diatonic_number_to_quality_dictionary(diatonic_number) do
    @diatonic_number_to_quality_dictionary[diatonic_number]
  end

  def size_to_quality(size) do
    diatonic_number_to_quality_dictionary(size)
    |> Map.keys()
  end
end
