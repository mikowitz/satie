defmodule Satie.Talea do
  @moduledoc """
  Models a cyclic talea
  """

  defstruct [:stream]

  def new(list) when is_list(list) do
    %__MODULE__{stream: Stream.cycle(list)}
  end

  def at(%__MODULE__{stream: stream}, index) do
    stream |> Stream.drop(index) |> Enum.at(0)
  end

  def drop(%__MODULE__{stream: stream}, n) do
    %__MODULE__{
      stream: Stream.drop(stream, n)
    }
  end

  def take(%__MODULE__{stream: stream}, n) do
    Enum.take(stream, n)
  end
end
