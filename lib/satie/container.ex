defmodule Satie.Container do
  @moduledoc """
  Models a simple container for holding other low-level score elements
  """
  defstruct [:contents]

  use Satie.Tree

  def new(contents \\ []) when is_list(contents) do
    case validate_contents(contents) do
      {:ok, contents} ->
        %__MODULE__{contents: contents}

      {:error, invalid_contents} ->
        {:error, :container_new, invalid_contents}
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

    def to_lilypond(%@for{contents: contents}, _opts) do
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
