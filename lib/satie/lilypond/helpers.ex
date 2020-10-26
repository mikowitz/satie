defmodule Satie.Lilypond.Helpers do
  def indent(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(fn line -> String.duplicate(" ", 2) <> line end)
    |> Enum.join("\n")
  end
end
