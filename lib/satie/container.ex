defmodule Satie.Container do
  @moduledoc false

  use Satie.Tree, [:simultaneous]

  def new(music, opts \\ []) do
    %__MODULE__{
      music: List.wrap(music),
      simultaneous: opts[:simultaneous],
      id: make_ref()
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Container do
  import Satie.Lilypond.Helpers

  def to_lilypond(%Satie.Container{music: music} = container, _) do
    {open_bracket, close_bracket} = bracket_pair(container)

    [
      open_bracket,
      Enum.map(music, fn m -> indent(Satie.to_lilypond(m)) end),
      close_bracket
    ]
    |> join()
  end

  defp bracket_pair(%Satie.Container{simultaneous: true}), do: {"<<", ">>"}
  defp bracket_pair(%Satie.Container{}), do: {"{", "}"}
end
