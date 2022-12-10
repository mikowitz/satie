defmodule Satie.Note do
  @moduledoc """
  Models a musical note
  """
  use Satie.Leaf, [:notehead]

  @note_re ~r/^(?<notehead>[^?!\d]+[?!]?)(?<duration>(\\breve|\\longa|\\maxima|\d+)\.*)$/

  alias Satie.{Duration, Notehead}

  def new(note) when is_bitstring(note) do
    case Regex.named_captures(@note_re, note) do
      %{"notehead" => notehead, "duration" => duration} ->
        new(Notehead.new(notehead), Duration.new(duration))

      nil ->
        {:error, :note_new, note}
    end
  end

  def new(%Notehead{} = notehead, %Duration{numerator: n, denominator: d} = duration) do
    case Duration.printable?(duration) do
      true ->
        %__MODULE__{
          written_duration: duration,
          notehead: notehead
        }

      false ->
        {:error, :note_new, {:unassignable_duration, n, d}}
    end
  end

  use Satie.Transposable, :notehead

  defimpl String.Chars do
    def to_string(%@for{notehead: notehead, written_duration: duration}) do
      Kernel.to_string(notehead) <> Kernel.to_string(duration)
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
      {attachments_before, attachments_after} = attachments_to_lilypond(note)

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
