defmodule Satie.Lilypond.OutputHelpers do
  def format_contents(contents) when is_list(contents) do
    contents
    |> Enum.map(fn elem ->
      elem
      |> Satie.ToLilypond.to_lilypond()
      |> indent()
    end)
  end

  def indent(s) when is_bitstring(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(&"  #{&1}")
    |> Enum.join("\n")
  end

  def indent(l) when is_list(l) do
    Enum.map(l, &indent/1)
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

  def ordered_attachments(attachments, position) do
    attachments
    |> Enum.filter(&(&1.position == position))
    |> Enum.sort_by(&Satie.IsAttachable.priority(&1.attachable))
  end

  def attachments_to_lilypond(%{attachments: attachments}) do
    [:before, :after]
    |> Enum.map(&ordered_attachments(attachments, &1))
    |> Enum.map(fn attachments ->
      Enum.map(attachments, &Satie.to_lilypond/1)
    end)
    |> List.to_tuple()
  end
end
