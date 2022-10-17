defmodule Satie.Tuplet do
  defstruct [:multiplier, :contents]

  alias Satie.Multiplier

  def new(multiplier, contents \\ [])

  def new(%Multiplier{} = multiplier, contents) do
    with {:ok, contents} <- validate_contents(contents) do
      %__MODULE__{multiplier: multiplier, contents: contents}
    else
      {:error, invalid_contents} -> {:error, :tuplet_new, invalid_contents}
    end
  end

  def new({numerator, denominator}, contents) do
    new(
      Multiplier.new(numerator, denominator),
      contents
    )
  end

  defp validate_contents(contents) do
    case Enum.filter(contents, &(!Satie.lilypondable?(&1))) do
      [] -> {:ok, contents}
      invalid_contents -> {:error, invalid_contents}
    end
  end

  defimpl String.Chars do
    def to_string(%@for{multiplier: multiplier, contents: contents}) do
      %Multiplier{numerator: n, denominator: d} = multiplier

      [
        "#{d}/#{n} {",
        Enum.map(contents, &String.Chars.to_string/1),
        "}"
      ]
      |> List.flatten()
      |> Enum.join(" ")
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = tuplet, _opts) do
      concat([
        "#Satie.Tuplet<",
        to_string(tuplet),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{multiplier: multiplier, contents: contents}) do
      %Multiplier{numerator: n, denominator: d} = multiplier

      [
        "\\tuplet #{d}/#{n} {",
        format_contents(contents),
        "}"
      ]
      |> List.flatten()
      |> Enum.join("\n")
    end
  end
end
