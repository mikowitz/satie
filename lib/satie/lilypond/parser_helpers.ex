defmodule Satie.Lilypond.Parser.Helpers do
  @moduledoc false
  def many(parser) do
    fn input ->
      case parser.(input) do
        {:error, _reason} ->
          {:ok, [], input}

        {:ok, first_term, rest} ->
          {:ok, other_terms, rest} = many(parser).(rest)
          {:ok, [first_term | other_terms], rest}
      end
    end
  end

  def maybe(parser) do
    fn input ->
      case parser.(input) do
        {:error, _reason} -> {:ok, [], input}
        {:ok, term, rest} -> {:ok, term, rest}
      end
    end
  end

  def some(parser) do
    fn input ->
      case parser.(input) do
        {:error, _reason} ->
          {:error, "term not found"}

        {:ok, first_term, rest} ->
          {:ok, other_terms, rest} = many(parser).(rest)
          {:ok, [first_term | other_terms], rest}
      end
    end
  end

  def sequence(parsers) do
    fn input ->
      case parsers do
        [] ->
          {:ok, [], input}

        [first_parser | other_parsers] ->
          with {:ok, first_term, rest} <- first_parser.(input),
               {:ok, other_terms, rest} <- sequence(other_parsers).(rest) do
            {:ok, [first_term | other_terms], rest}
          end
      end
    end
  end

  def choice(parsers) do
    fn input ->
      case parsers do
        [] ->
          {:error, "no parser succeeded"}

        [first_parser | other_parsers] ->
          with {:error, _reason} <- first_parser.(input) do
            choice(other_parsers).(input)
          end
      end
    end
  end

  def satisfy(parser, condition) do
    fn input ->
      with success = {:ok, term, _rest} <- parser.(input) do
        if condition.(term),
          do: success,
          else: {:error, "term rejected"}
      end
    end
  end

  def resolve(parser, resolver) do
    fn input ->
      with {:ok, term, rest} <- parser.(input) do
        {:ok, resolver.(term), rest}
      end
    end
  end

  def token(parser) do
    sequence([
      many(choice([char(?\s), char(?\n), char(?\t)])),
      parser,
      many(choice([char(?\s), char(?\n), char(?\t)]))
    ])
    |> resolve(fn [_, term, _] -> term end)
  end

  def digit do
    satisfy(
      char(),
      fn c -> c in ?0..?9 end
    )
  end

  def char(expected) do
    satisfy(
      char(),
      fn c -> c == expected end
    )
  end

  def word(word) do
    token(
      sequence(
        word
        |> to_charlist
        |> Enum.map(fn c -> char(c) end)
      )
    )
  end

  def char do
    fn input ->
      case input do
        "" -> {:error, "unexpected end of input"}
        <<char::utf8, rest::binary>> -> {:ok, char, rest}
      end
    end
  end

  def lazy(combinator) do
    fn input ->
      parser = combinator.()
      parser.(input)
    end
  end
end
