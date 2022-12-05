defprotocol Satie.HasDirection do
  @fallback_to_any true
  def has_direction?(obj)
end

defimpl Satie.HasDirection, for: Any do
  def has_direction?(_), do: false
end
