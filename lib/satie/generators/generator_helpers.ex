defmodule Satie.Generators.GeneratorHelpers do
  @moduledoc """
    Helper functions for Satie generators
  """

  alias Satie.{Fraction, Note, Rest, Tie}

  def remove_final_tie(staff) do
    update_in(staff, [Satie.leaf(-1)], fn note ->
      attachments = Enum.reject(note.attachments, &is_struct(&1.attachable, Satie.Tie))

      %{note | attachments: attachments}
    end)
  end

  def validate_fractions(fractions) do
    fractions = Enum.map(fractions, &Fraction.new/1)

    case Enum.filter(fractions, &is_tuple/1) do
      [] -> {:ok, fractions}
      bad_fractions -> {:error, :fill_rhythm_generator_new, Enum.map(bad_fractions, &elem(&1, 2))}
    end
  end

  def tie_chain([]), do: []
  def tie_chain([leaf]), do: [leaf]

  def tie_chain(leaves) do
    [last | head] = Enum.reverse(leaves)

    leaves =
      Enum.map(head, &attach_tie_if_not_tied/1)
      |> Enum.reverse()

    leaves ++ [last]
  end

  def attach_tie_if_not_tied(%Note{attachments: attachments} = note) do
    case Enum.any?(attachments, &is_struct(&1.attachable, Satie.Tie)) do
      true -> note
      false -> Satie.attach(note, Tie.new())
    end
  end

  def attach_tie_if_not_tied(%Rest{} = rest), do: rest
end
