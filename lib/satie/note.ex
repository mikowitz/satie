defmodule Satie.Note do
  @moduledoc """
  Models a musical note
  """
  use Satie.Leaf, [:notehead]

  def new(note), do: Satie.ToNote.from(note)

  def new(notehead, duration), do: new({notehead, duration})

  use Satie.Transposable, :notehead

  defimpl String.Chars do
    def to_string(%@for{notehead: notehead, written_duration: duration}) do
      Kernel.to_string(notehead) <> Satie.to_lilypond(duration)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = note, _opts) do
      concat([
        "#Satie.Note<",
        to_string(note),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{} = note, _opts) do
      %{before: attachments_before, after: attachments_after} = attachments_to_lilypond(note)

      [
        attachments_before,
        to_string(note),
        Enum.map(attachments_after, &indent/1)
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end
  end
end
