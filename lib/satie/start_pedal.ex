defmodule Satie.StartPedal do
  @moduledoc """
  Models a pedal down event
  """

  use Satie.Attachable, fields: [:pedal], has_direction: false

  @valid_pedals ~w(sustain sostenuto corda)a

  def new(pedal \\ :sustain)

  def new(pedal) when pedal in @valid_pedals do
    %__MODULE__{
      pedal: pedal,
      components: [
        after: [_component(pedal)]
      ]
    }
  end

  def new(pedal) when is_bitstring(pedal) do
    case String.to_atom(pedal) do
      pedal when pedal in @valid_pedals -> new(pedal)
      _ -> {:error, :start_pedal_new, pedal}
    end
  end

  def new(pedal), do: {:error, :start_pedal_new, pedal}

  def _component(:sustain), do: "\\sustainOn"
  def _component(:sostenuto), do: "\\sostenutoOn"
  def _component(:corda), do: "\\unaCorda"

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{pedal: pedal}, _opts) do
      concat([
        "#Satie.StartPedal<",
        to_string(pedal),
        ">"
      ])
    end
  end
end
