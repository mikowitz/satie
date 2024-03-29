defmodule Satie.Lilypond.OutputHelpers do
  @moduledoc """
    Implements helper functions for constructing Lilypond output
  """

  def format_contents(contents) when is_list(contents) do
    contents
    |> Enum.map(fn elem ->
      elem
      |> Satie.to_lilypond()
      |> indent()
    end)
  end

  def indent(indentable, depth \\ 1)

  def indent(nil, _), do: nil

  def indent(s, depth) when is_bitstring(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map_join("\n", &"#{String.duplicate("  ", depth)}#{&1}")
  end

  def indent(l, depth) when is_list(l) do
    Enum.map(l, &indent(&1, depth))
  end

  def delimiters_for_simultaneous(true), do: {"<<", ">>"}
  def delimiters_for_simultaneous(false), do: {"{", "}"}

  def context_signature(context_name, name \\ nil)

  def context_signature(context_name, nil) do
    "\\new #{context_name}"
  end

  def context_signature(context_name, name) do
    ~s(\\context #{context_name} = "#{to_string(name)}")
  end

  def attachments_to_lilypond(%{attachments: attachments}) do
    attachments
    |> Enum.reverse()
    |> Enum.map(&Satie.Attachment.prepared_components/1)
    |> Enum.reduce([before: [], after: []], fn components, acc ->
      Keyword.merge(acc, components, fn _k, v1, v2 -> v1 ++ v2 end)
    end)
    |> Enum.map(fn {k, v} ->
      {
        k,
        Enum.sort_by(v, &elem(&1, 2))
        |> Enum.map(&elem(&1, 0))
      }
    end)
    |> Enum.into(%{})
  end
end
