defmodule Satie.Spacer do
  @moduledoc """
  Models an unprinted spacer rest
  """
  use Satie.Leaf

  def new(spacer), do: Satie.ToSpacer.from(spacer)

  defimpl String.Chars do
    def to_string(%@for{} = spacer) do
      Satie.to_lilypond(spacer)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = spacer, _opts) do
      concat([
        "#Satie.Spacer<",
        Satie.to_lilypond(spacer),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{written_duration: duration} = spacer, _opts) do
      {attachments_before, attachments_after} = attachments_to_lilypond(spacer)

      [
        attachments_before,
        "s" <> Satie.to_lilypond(duration),
        attachments_after
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end
  end
end
