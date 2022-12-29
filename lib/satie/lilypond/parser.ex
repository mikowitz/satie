defmodule Satie.Lilypond.Parser do
  @moduledoc """
    Parser for basic lilypond input
  """

  def accidental do
    maybe(
      one_of([
        token("+"),
        token("~"),
        accidental_parser(?s),
        accidental_parser(?f)
      ])
    )
    |> map(&to_string/1)
  end

  def chord do
    sequence([
      char(?<),
      whitespace(),
      many(
        sequence([
          notehead(),
          whitespace()
        ])
      ),
      char(?>),
      duration()
    ])
    |> map(fn [_, _, noteheads, _, duration] ->
      [
        Enum.map(noteheads, fn [notehead, _] -> Enum.join(notehead) end),
        Enum.join(duration)
      ]
    end)
  end

  def duration do
    sequence([
      one_of([
        power_of_two(),
        named_duration()
      ]),
      many(char(?.))
    ])
    |> map(fn [base, dots] -> [to_string(base), to_string(dots)] end)
  end

  def fraction do
    sequence([
      some(digit()),
      char(?/),
      some(digit())
    ])
    |> map(fn [n, _, d] ->
      with {n, ""} <- Integer.parse(to_string(n)),
           {d, ""} <- Integer.parse(to_string(d)),
           do: [n, d]
    end)
  end

  def note do
    sequence([
      notehead(),
      duration()
    ])
    |> map(fn [notehead, duration] -> [Enum.join(notehead), Enum.join(duration)] end)
  end

  def notehead do
    sequence([
      pitch(),
      maybe(
        one_of([
          char(??),
          char(?!)
        ])
      )
    ])
    |> map(fn [pitch, accidental_display] ->
      [Enum.join(pitch), to_string([accidental_display])]
    end)
  end

  def pitch do
    sequence([
      pitch_class(),
      maybe(octave())
    ])
    |> map(fn [pitch_class, octave] -> [Enum.join(pitch_class), to_string(octave)] end)
  end

  def pitch_class do
    sequence([
      diatonic_pitch_class(),
      accidental()
    ])
    |> map(fn [dpc, acc] -> [to_string([dpc]), acc] end)
  end

  def rest do
    rest_parser(?r)
  end

  def spacer do
    rest_parser(?s)
  end

  ## LILYPOND HELPERS

  defp accidental_parser(ch) do
    one_of([
      token("tq#{[ch]}"),
      sequence([char(?q), char(ch)]),
      sequence([
        some(char(ch)),
        maybe(sequence([char(?q), char(ch)]))
      ])
      |> map(&Enum.join/1)
    ])
  end

  defp diatonic_pitch_class do
    satisfy(char(), fn ch -> ch in ?a..?g end)
  end

  defp named_duration do
    one_of([
      token("\\breve"),
      token("\\longa"),
      token("\\maxima")
    ])
  end

  defp octave do
    one_of([
      some(char(?')),
      some(char(?,))
    ])
  end

  defp power_of_two do
    digit()
    |> some()
    |> map(fn num -> with {int, ""} <- Integer.parse(to_string(num)), do: int end)
    |> satisfy(fn num ->
      log = :math.log2(num)
      log == round(log)
    end)
  end

  defp rest_parser(ch) do
    sequence([
      maybe(char(ch)),
      duration()
    ])
    |> map(fn [_, duration] -> Enum.join(duration) end)
  end

  defp whitespace do
    many(whitespace_char())
  end

  defp whitespace_char do
    satisfy(char(), fn char -> char in [?\s, ?\t, ?\n, ?\r] end)
  end

  ### PARSER FUNCTIONS

  defp char do
    fn input ->
      case input do
        "" -> {:error, "unexpected end of input", input}
        <<char::utf8, rest::binary>> -> {:ok, char, rest}
      end
    end
  end

  defp char(expected) do
    char()
    |> satisfy(fn char -> char == expected end)
  end

  defp digit do
    satisfy(char(), fn char -> char in ?0..?9 end)
  end

  defp many(parser) do
    fn input ->
      case parser.(input) do
        {:error, _, _} ->
          {:ok, [], input}

        {:ok, first_term, rest} ->
          with {:ok, other_terms, rest} <- many(parser).(rest),
               do: {:ok, [first_term | other_terms], rest}
      end
    end
  end

  defp map(parser, mapper) do
    fn input ->
      with {:ok, term, rest} <- parser.(input),
           do: {:ok, mapper.(term), rest}
    end
  end

  defp maybe(parser) do
    fn input ->
      case parser.(input) do
        {:ok, term, rest} -> {:ok, term, rest}
        {:error, _, _} -> {:ok, [], input}
      end
    end
  end

  defp one_of(parsers) do
    fn input ->
      case parsers do
        [] ->
          {:error, "no matching parsers", input}

        [first_parser | other_parsers] ->
          with {:error, _, _} <- first_parser.(input),
               do: one_of(other_parsers).(input)
      end
    end
  end

  defp satisfy(parser, acceptor) do
    fn input ->
      with {:ok, term, rest} <- parser.(input) do
        if acceptor.(term),
          do: {:ok, term, rest},
          else: {:error, "term rejected", term}
      end
    end
  end

  defp sequence(parsers) do
    fn input ->
      case parsers do
        [] ->
          {:ok, [], input}

        [first_parser | other_parsers] ->
          with {:ok, first_term, rest} <- first_parser.(input),
               {:ok, other_terms, rest} <- sequence(other_parsers).(rest),
               do: {:ok, [first_term | other_terms], rest}
      end
    end
  end

  defp some(parser) do
    parser
    |> many()
    |> satisfy(&(&1 != []))
  end

  defp token(expected) do
    expected
    |> to_charlist()
    |> Enum.map(&char(&1))
    |> sequence()
  end
end
