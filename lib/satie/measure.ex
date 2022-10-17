defmodule Satie.Measure do
  defstruct [:time_signature, :contents]

  alias Satie.TimeSignature

  def new(time_signature, contents \\ [])

  def new({numerator, denominator}, contents) do
    new(
      TimeSignature.new(numerator, denominator),
      contents
    )
  end

  def new(%TimeSignature{} = time_signature, contents) do
    with {:ok, contents} <- validate_contents(contents) do
      %__MODULE__{time_signature: time_signature, contents: contents}
    else
      {:error, invalid_contents} -> {:error, :measure_new, invalid_contents}
    end
  end

  defp validate_contents(contents) do
    case Enum.filter(contents, &(!Satie.lilypondable?(&1))) do
      [] -> {:ok, contents}
      invalid_contents -> {:error, invalid_contents}
    end
  end

  defimpl String.Chars do
    def to_string(%@for{time_signature: time_signature, contents: contents}) do
      %TimeSignature{numerator: n, denominator: d} = time_signature

      [
        "{",
        "#{n}/#{d}",
        Enum.map(contents, &@protocol.to_string/1),
        "}"
      ]
      |> List.flatten()
      |> Enum.join(" ")
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = measure, _opts) do
      concat([
        "#Satie.Measure<",
        to_string(measure),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{time_signature: time_signature, contents: contents}) do
      %TimeSignature{numerator: n, denominator: d} = time_signature

      [
        "{",
        indent("\\time #{n}/#{d}"),
        format_contents(contents),
        indent("|"),
        "}"
      ]
      |> List.flatten()
      |> Enum.join("\n")
    end
  end
end
