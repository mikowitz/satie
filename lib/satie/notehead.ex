defmodule Satie.Notehead do
  defstruct [:written_pitch, :accidental_display]

  alias Satie.Pitch

  def new(%Pitch{} = pitch, opts \\ []) do
    %__MODULE__{
      written_pitch: pitch,
      accidental_display: accidental_display_from_opts(opts)
    }
  end

  @accidental_display_options ~w(forced cautionary neutral)a

  defp accidental_display_from_opts(opts) do
    Enum.find(@accidental_display_options, :neutral, &(&1 == opts[:accidental_display]))
  end

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
    def to_lilypond(%@for{} = notehead), do: to_string(notehead)
  end
end
