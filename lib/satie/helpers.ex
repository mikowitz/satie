defmodule Satie.Helpers do
  def interval_regex do
    ~r/^
      (?<polarity>[-+]?)
      (?<quality>m|M|P|d+|A+)
      (?<quartertone>[~+]?)
      (?<size>\d+)
    $/x
  end

  def size_to_quality(size) do
    %{
      1 => ~w(d P A),
      2 => ~w(d m M A),
      3 => ~w(d m M A),
      4 => ~w(d P A),
      5 => ~w(d P A),
      6 => ~w(d m M A),
      7 => ~w(d m M A),
      8 => ~w(d P A)
    }[size]
  end

  def size_to_semitones(size) do
    %{
      1 => 0,
      2 => 2,
      3 => 4,
      4 => 5,
      5 => 7,
      6 => 9,
      7 => 11,
      8 => 12
    }[abs(size)]
  end

  @perfect_qualities %{"d" => -1, "P" => 0, "A" => 1}
  @major_minor_qualities %{"d" => -2, "m" => -1, "M" => 0, "A" => 1}

  @size_to_quality_semitones %{
    1 => @perfect_qualities,
    2 => @major_minor_qualities,
    3 => @major_minor_qualities,
    4 => @perfect_qualities,
    5 => @perfect_qualities,
    6 => @major_minor_qualities,
    7 => @major_minor_qualities,
    8 => @perfect_qualities
  }

  def quality_to_semitones(size, quality) do
    normal_size = normalize_size(size)
    size_qualities = @size_to_quality_semitones[abs(normal_size)]

    case size_qualities[quality] do
      n when is_integer(n) ->
        n

      nil ->
        case quality do
          "A" <> _ -> String.length(quality)
          "d" <> q -> size_qualities["d"] - String.length(q)
        end
    end
  end

  def normalize_size(size) when size > 7, do: normalize_size(size - 7)
  def normalize_size(size), do: size

  def parse_polarity(%{polarity: "-"} = map), do: %{map | polarity: -1}
  def parse_polarity(%{polarity: _} = map), do: %{map | polarity: 1}

  def polarity_to_string(-1), do: "-"
  def polarity_to_string(1), do: "+"
  def polarity_to_string(0), do: ""

  def parse_size(%{size: size} = map) do
    {size, ""} = Integer.parse(size)
    %{map | size: size}
  end

  def validate_quality(%{quality: quality, size: size} = map, struct_type) do
    normal_size = normalize_size(size)

    case String.first(quality) in size_to_quality(normal_size) do
      true -> map
      false -> {:error, :"#{struct_type}_invalid_quality", {quality, size}}
    end
  end

  def append_quartertone_to_quality(%{quartertone: quartertone, quality: quality} = map) do
    %{map | quality: quality <> quartertone}
  end

  def build_name(%{quality: quality, size: size, polarity: polarity} = map) do
    Map.put(map, :name, "#{polarity_to_string(polarity)}#{quality}#{abs(size)}")
  end

  def is_perfect_unison?(%{quality: "P", size: 1, quartertone: ""}), do: true
  def is_perfect_unison?(_), do: false

  def is_octave?(%{size: size}, 1) when abs(size) >= 8, do: true
  def is_octave?(_, _), do: false

  def is_perfect?(%{quality: "P", quartertone: ""}), do: true
  def is_perfect?(_), do: false

  def is_diminished_or_quarter_flat?(%{quality: "d" <> _}), do: true
  def is_diminished_or_quarter_flat?(%{quality: "P", quartertone: "~"}), do: true
  def is_diminished_or_quarter_flat?(_), do: false

  def quartertone_string_to_number(""), do: 0.0
  def quartertone_string_to_number("+"), do: 0.5
  def quartertone_string_to_number("~"), do: -0.5
end
