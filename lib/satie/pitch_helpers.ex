defmodule Satie.PitchHelpers do
  @dpc_to_semitones %{
    "c" => 0,
    "d" => 2,
    "e" => 4,
    "f" => 5,
    "g" => 7,
    "a" => 9,
    "b" => 11
  }

  @dpc_to_staff_spaces %{
    "c" => 0,
    "d" => 1,
    "e" => 2,
    "f" => 3,
    "g" => 4,
    "a" => 5,
    "b" => 6
  }

  @staff_spaces_to_dpc %{
    0 => "c",
    1 => "d",
    2 => "e",
    3 => "f",
    4 => "g",
    5 => "a",
    6 => "b"
  }

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
end
