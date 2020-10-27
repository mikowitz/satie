defmodule Satie.Lilypond.Helpers do
  @moduledoc false

  def indent(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(fn line -> String.duplicate(" ", 2) <> line end)
    |> Enum.join("\n")
  end
end
