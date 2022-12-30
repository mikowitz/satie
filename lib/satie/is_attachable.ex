defprotocol Satie.IsAttachable do
  @fallback_to_any true
  def attachable?(obj)

  def priority(obj)
end

defimpl Satie.IsAttachable, for: Any do
  def attachable?(_), do: false

  def priority(_), do: nil
end
