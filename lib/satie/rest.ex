defmodule Satie.Rest do
  @moduledoc """
  Models a rest
  """
  use Satie.Leaf

  def new(rest), do: Satie.ToRest.from(rest)

  defimpl String.Chars do
    def to_string(%@for{} = rest) do
      Satie.to_lilypond(rest)
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = rest, _opts) do
      concat([
        "#Satie.Rest<",
        Satie.to_lilypond(rest),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{written_duration: duration} = rest, _opts) do
      %{before: attachments_before, after: attachments_after} = attachments_to_lilypond(rest)

      [
        attachments_before,
        "r" <> Satie.to_lilypond(duration),
        Enum.map(attachments_after, &indent/1)
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end
  end
end
