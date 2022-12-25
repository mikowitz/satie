defprotocol Satie.ToAccidental do
  @fallback_to_any true
  def from(_)
end

defimpl Satie.ToAccidental, for: Any do
  def from(x), do: {:error, :accidental_new, x}
end

defimpl Satie.ToAccidental, for: Satie.Accidental do
  def from(accidental), do: accidental
end

defimpl Satie.ToAccidental, for: BitString do
  import Satie.AccidentalHelpers, only: [correct_name: 1, calculate_semitones: 1]

  def from(accidental) do
    case Satie.Lilypond.Parser.accidental().(accidental) do
      {:ok, name, ""} ->
        %{name: name}
        |> correct_name()
        |> calculate_semitones()
        |> then(&struct(Satie.Accidental, &1))

      _ ->
        {:error, :accidental_new, accidental}
    end
  end
end

defimpl Satie.ToAccidental, for: Integer do
  def from(accidental), do: @protocol.from(accidental / 1)
end

defimpl Satie.ToAccidental, for: Float do
  import Satie.AccidentalHelpers,
    only: [
      semitones_to_name: 1,
      calculate_quartertone: 1,
      calculate_accidental_char: 1,
      calculate_name: 1
    ]

  def from(semitones) do
    case semitones_to_name(semitones) do
      name when is_bitstring(name) ->
        %Satie.Accidental{name: name, semitones: semitones}

      nil ->
        %{
          semitones: semitones
        }
        |> calculate_quartertone()
        |> calculate_accidental_char()
        |> calculate_name()
        |> Map.take([:name, :semitones])
        |> then(&struct(Satie.Accidental, &1))
    end
  end
end
