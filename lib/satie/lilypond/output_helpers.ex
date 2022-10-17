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
end
