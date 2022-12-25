defmodule Satie.Attachment do
  @moduledoc """
  Models a wrapper for an attachable object as it is attached to a target object
  """

  defstruct [:attachable, :direction, :position, :priority]

  alias Satie.IsAttachable

  @doc """

      iex> accent = Articulation.new("accent")
      iex> Attachment.new(accent)
      #Satie.Attachment<- \\accent>

      iex> accent = Articulation.new("accent")
      iex> Attachment.new(accent, direction: :up)
      #Satie.Attachment<^ \\accent>

      iex> clef = Clef.new("treble")
      iex> Attachment.new(clef)
      #Satie.Attachment<\\clef "treble">

  """
  def new(attachable, options \\ []) do
    direction = Keyword.get(options, :direction, nil)

    position = Keyword.get(options, :position, IsAttachable.location(attachable))
    priority = Keyword.get(options, :priority, IsAttachable.priority(attachable))

    %__MODULE__{
      attachable: attachable,
      direction: direction,
      position: position,
      priority: priority
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = attachment, _opts) do
      concat([
        "#Satie.Attachment<",
        Satie.to_lilypond(attachment),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{attachable: attachable, direction: direction}, _opts) do
      [
        direction_indicator(attachable, direction),
        Satie.to_lilypond(attachable)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")
    end

    defp direction_indicator(attachable, direction) do
      case Satie.HasDirection.has_direction?(attachable) do
        true -> Satie.StringHelpers.direction_indicator(direction)
        false -> nil
      end
    end
  end
end
