defmodule Satie.Lilypond.Helpers do
  @moduledoc false

  def join(contents, joiner \\ "\n") do
    contents
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.join(joiner)
  end

  @before_leaf_attachments [Satie.Command]

  def before_leaf_attachments_to_lilypond(attachments) when is_list(attachments) do
    attachments
    |> Enum.filter(&(&1.__struct__ in @before_leaf_attachments))
    |> Enum.map(&Satie.to_lilypond/1)
  end

  def attachments_to_lilypond(attachments) when is_list(attachments) do
    attachments
    |> Enum.reject(&(&1.__struct__ in @before_leaf_attachments))
    |> Enum.map(&Satie.to_lilypond/1)
    |> indent
  end

  def spanners_to_lilypond(spanners) when is_list(spanners) do
    spanners
    |> Enum.map(fn {spanner, position} ->
      indent(Satie.to_lilypond(spanner, spanner_position: position))
    end)
  end

  def indent(nil), do: nil

  def indent(str) when is_bitstring(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(fn line -> String.duplicate(" ", 2) <> line end)
    |> Enum.join("\n")
  end

  def indent([]), do: nil

  def indent(list) when is_list(list) do
    Enum.map(list, &indent/1)
  end
end
