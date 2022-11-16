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

  def ordered_attachments(attachments, location) do
    attachments
    |> Enum.filter(fn attachment -> Satie.IsAttachable.location(attachment) == location end)
    |> Enum.sort_by(&Satie.IsAttachable.priority(&1))
  end

  def attachments_to_lilypond(%{attachments: attachments}) do
    attachments_before = ordered_attachments(attachments, :before)

    attachments_after = ordered_attachments(attachments, :after)

    [attachments_before, attachments_after]
    |> Enum.map(fn attachments ->
      Enum.map(attachments, &Satie.to_lilypond/1)
    end)
    |> List.to_tuple()
  end
end
