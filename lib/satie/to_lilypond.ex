defprotocol Satie.ToLilypond do
  @fallback_to_any true

  def to_lilypond(music, opts \\ [])
end

defimpl Satie.ToLilypond, for: Any do
  def to_lilypond(x, _), do: inspect(x)
end
