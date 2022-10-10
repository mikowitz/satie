defmodule Satie.Note do
  defstruct [:written_duration, :notehead]

  alias Satie.{Duration, Notehead}

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
    def to_lilypond(%@for{} = note), do: to_string(note)
  end
end
