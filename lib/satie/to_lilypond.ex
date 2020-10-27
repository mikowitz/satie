defprotocol Satie.ToLilypond do
  @fallback_to_any true

  def to_lilypond(music)
end

defimpl Satie.ToLilypond, for: Any do
  def to_lilypond(x), do: inspect(x)
end
