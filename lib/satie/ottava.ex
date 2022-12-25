defmodule Satie.Ottava do
  @moduledoc """
    Models an ottava setting
  """

  defstruct [:degree]

  use Satie.Attachable, has_direction: false

  def new(degree) when is_integer(degree) do
    %__MODULE__{degree: degree}
  end

  def new(degree), do: {:error, :ottava_new, degree}

  defimpl String.Chars do
    def to_string(%@for{degree: degree}) do
      "\\ottava ##{degree}"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{degree: degree}, _opts) do
      concat([
        "#Satie.Ottava<",
        inspect(degree),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{degree: degree}, _) do
      "\\ottava ##{degree}"
    end
  end
end
