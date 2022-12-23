defmodule Satie.Notehead do
  @moduledoc """
  Models a notehead that belongs to a note or chord
  """
  defstruct [:written_pitch, :accidental_display]

  def new(notehead, opts \\ nil)
  def new(notehead, nil), do: Satie.ToNotehead.from(notehead)
  def new(notehead, opts), do: Satie.ToNotehead.from({notehead, opts})

  use Satie.Transposable, :written_pitch

  defimpl String.Chars do
    def to_string(%@for{written_pitch: pitch, accidental_display: accidental_display}) do
      Kernel.to_string(pitch) <> accidental_display_to_string(accidental_display)
    end

    defp accidental_display_to_string(:cautionary), do: "?"
    defp accidental_display_to_string(:forced), do: "!"
    defp accidental_display_to_string(:neutral), do: ""
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = notehead, _opts) do
      concat([
        "#Satie.Notehead<",
        to_string(notehead),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = notehead, _opts), do: to_string(notehead)
  end
end
