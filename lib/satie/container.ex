defmodule Satie.Container do
  defstruct [:contents]

  def new(contents \\ []) when is_list(contents) do
    with {:ok, contents} <- validate_contents(contents) do
      %__MODULE__{contents: contents}
    else
      {:error, invalid_contents} -> {:error, :container_new, invalid_contents}
    end
  end

  defp validate_contents(contents) do
    case Enum.filter(contents, &(!Satie.lilypondable?(&1))) do
      [] -> {:ok, contents}
      invalid_contents -> {:error, invalid_contents}
    end
  end

  defimpl String.Chars do
    def to_string(%@for{contents: contents}) do
      [
        "{",
        Enum.map(contents, &String.Chars.to_string/1),
        "}"
      ]
      |> List.flatten()
      |> Enum.join(" ")
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = container, _opts) do
      concat([
        "#Satie.Container<",
        to_string(container),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{contents: contents}) do
      [
        "{",
        format_contents(contents),
        "}"
      ]
      |> List.flatten()
      |> Enum.join("\n")
    end
  end
end
