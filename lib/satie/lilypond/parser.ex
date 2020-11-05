defmodule Satie.Lilypond.Parser do
  @moduledoc false
  @naturals_map %{
    ?c => 0,
    ?d => 2,
    ?e => 4,
    ?f => 5,
    ?g => 7,
    ?a => 9,
    ?b => 11
  }

  # use Satie.Lilypond.Parser.Helpers
  import Satie.Lilypond.Parser.Helpers

  def parse(input) do
    parser = choice([leaf(), tree()])
    {:ok, result, _} = parser.(input)
    {:ok, result}
  end

  defp leaf do
    choice([
      chord(),
      note(),
      rest()
    ])
  end

  defp tree do
    choice([
      container(),
      measure(),
      tuplet()
    ])
  end

  defp nestable_tree do
    choice([
      container(),
      tuplet()
    ])
  end

  defp container do
    bracketed_music()
    |> resolve(fn [?{, leaves, ?}] ->
      Satie.Container.new(leaves)
    end)
  end

  defp measure do
    sequence([
      token(char(?{)),
      word("\\time"),
      fraction(),
      many(
        choice([
          leaf(),
          lazy(fn -> nestable_tree() end)
        ])
      ),
      token(char(?}))
    ])
    |> resolve(fn [_, _, [n, d], music, _] ->
      Satie.Measure.new({n, d}, music)
    end)
  end

  defp tuplet do
    sequence([
      word("\\tuplet"),
      fraction(),
      bracketed_music()
    ])
    |> resolve(fn [_, [d, n], [_, music, _]] ->
      Satie.Tuplet.new({n, d}, music)
    end)
  end

  defp bracketed_music do
    sequence([
      token(char(?{)),
      many(
        choice([
          leaf(),
          lazy(fn -> tree() end)
        ])
      ),
      token(char(?}))
    ])
  end

  defp fraction do
    sequence([
      token(some(digit())),
      char(?/),
      token(some(digit()))
    ])
    |> resolve(fn [n, ?/, d] ->
      [n, d]
      |> Enum.map(&:string.to_integer/1)
      |> Enum.map(fn {x, _} -> x end)
    end)
  end

  defp chord do
    sequence([
      token(char(?<)),
      some(token(pitch())),
      token(char(?>)),
      duration()
    ])
    |> resolve(fn [_, pitches, _, [dur, dots]] ->
      pitches = calculate_pitches(pitches)
      duration = calculate_duration(dur, dots)

      Satie.Chord.new(
        pitches,
        duration
      )
    end)
  end

  defp note do
    token(
      sequence([
        pitch(),
        duration()
      ])
    )
    |> resolve(fn [[pitch, accidental, octave], [dur, dots]] ->
      duration = calculate_duration(dur, dots)

      Satie.Note.new(
        calculate_pitch(pitch, accidental, octave),
        duration
      )
    end)
  end

  defp rest do
    token(
      sequence([
        choice([char(?r), char(?s)]),
        duration()
      ])
    )
    |> resolve(fn [rest_char, [dur, dots]] ->
      duration = calculate_duration(dur, dots)

      case rest_char do
        ?r -> Satie.Rest.new(duration)
        ?s -> Satie.Spacer.new(duration)
      end
    end)
  end

  defp pitch do
    sequence([
      natural(),
      maybe(accidental()),
      maybe(octave())
    ])
  end

  defp accidental do
    choice([
      char(?s),
      char(?f)
    ])
  end

  defp natural do
    satisfy(
      char(),
      fn c -> c in ?a..?g end
    )
  end

  defp octave do
    choice([
      some(char(?,)),
      some(char(?'))
    ])
  end

  defp duration do
    sequence([
      many(digit()),
      many(char(?.))
    ])
  end

  defp calculate_pitches(pitches) do
    pitches
    |> Enum.map(fn [pitch, accidental, octave] ->
      calculate_pitch(pitch, accidental, octave)
    end)
  end

  defp calculate_pitch(pitchname, accidental, octave) do
    Satie.Pitch.new(
      @naturals_map[pitchname] + calculate_accidental(accidental),
      calculate_octave(octave)
    )
  end

  defp calculate_duration(dur, dots) do
    base_duration = dur |> to_string() |> String.to_integer()
    dots_count = length(dots)
    num = round(:math.pow(2, dots_count + 1) - 1)
    denom = round(base_duration * :math.pow(2, dots_count))
    Satie.Duration.new(num, denom)
  end

  defp calculate_accidental([]), do: 0
  defp calculate_accidental(?f), do: -1
  defp calculate_accidental(?s), do: 1

  defp calculate_octave([]), do: 3
  defp calculate_octave([?, | _] = octave), do: 3 - length(octave)
  defp calculate_octave([?' | _] = octave), do: 3 + length(octave)
end
