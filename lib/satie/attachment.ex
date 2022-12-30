defmodule Satie.Attachment do
  @moduledoc """
  Models a wrapper for an attachable object as it is attached to a target object
  """

  defstruct [:attachable, :direction, :position, :priority]

  alias Satie.IsAttachable

  def new(attachable, options \\ []) do
    direction =
      case Satie.HasDirection.has_direction?(attachable) do
        true -> Keyword.get(options, :direction, :neutral)
        false -> nil
      end

    position = Keyword.get(options, :position)
    priority = Keyword.get(options, :priority, IsAttachable.priority(attachable))

    %__MODULE__{
      attachable: attachable,
      direction: direction,
      position: position,
      priority: priority
    }
  end

  def prepared_components(%__MODULE__{
        attachable: %{components: components},
        priority: priority,
        direction: direction,
        position: position
      }) do
    components
    |> Enum.map(fn {k, v} ->
      Enum.map(v, fn v -> {with_direction(v, direction), position || k, priority} end)
    end)
    |> List.flatten()
    |> Enum.group_by(&elem(&1, 1))
    |> Enum.into([])
  end

  defp with_direction(str, nil), do: str
  defp with_direction(str, :neutral), do: "- #{str}"
  defp with_direction(str, :up), do: "^ #{str}"
  defp with_direction(str, :down), do: "_ #{str}"
end
