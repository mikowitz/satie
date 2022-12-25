defmodule Satie.StopPedal do
  @moduledoc """
  Models a pedal up event
  """

  defstruct [:pedal]

  use Satie.Attachable

  @valid_pedals ~w(sustain sostenuto corda)a

  def new(pedal \\ :sustain)

  def new(pedal) when pedal in @valid_pedals do
    %__MODULE__{pedal: pedal}
  end

  def new(pedal) when is_bitstring(pedal) do
    case String.to_atom(pedal) do
      pedal when pedal in @valid_pedals -> new(pedal)
      _ -> {:error, :stop_pedal_new, pedal}
    end
  end

  def new(pedal), do: {:error, :stop_pedal_new, pedal}

  defimpl String.Chars do
    def to_string(%@for{pedal: :sustain}), do: "\\sustainOff"
    def to_string(%@for{pedal: :sostenuto}), do: "\\sostenutoOff"
    def to_string(%@for{pedal: :corda}), do: "\\treCorde"
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{pedal: pedal}, _opts) do
      concat([
        "#Satie.StopPedal<",
        to_string(pedal),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{pedal: :sustain}, _), do: "\\sustainOff"
    def to_lilypond(%@for{pedal: :sostenuto}, _), do: "\\sostenutoOff"
    def to_lilypond(%@for{pedal: :corda}, _), do: "\\treCorde"
  end
end
