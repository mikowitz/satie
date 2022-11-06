defmodule Satie.Score do
  defstruct [:contents, :name, :simultaneous]

  use Satie.Tree

  def new(contents \\ [], opts \\ []) do
    with {:ok, contents} <- validate_contents(contents) do
      %__MODULE__{
        contents: contents,
        name: Keyword.get(opts, :name, nil),
        simultaneous: Keyword.get(opts, :simultaneous, true)
      }
    else
      {:error, invalid_contents} -> {:error, :score_new, invalid_contents}
    end
  end

  def set_simultaneous(%__MODULE__{} = staff, simultaneous) when is_boolean(simultaneous) do
    %{staff | simultaneous: simultaneous}
  end

  def set_name(%__MODULE__{} = voice, ""), do: clear_name(voice)

  def set_name(%__MODULE__{} = voice, name) when is_bitstring(name) do
    %{voice | name: name}
  end

  def clear_name(%__MODULE__{} = voice), do: %{voice | name: nil}

  defp validate_contents(contents) do
    case Enum.filter(contents, &(!Satie.lilypondable?(&1))) do
      [] -> {:ok, contents}
      invalid_contents -> {:error, invalid_contents}
    end
  end

  defimpl String.Chars do
    def to_string(%@for{name: name, simultaneous: simultaneous, contents: contents}) do
      {opening, closing} = delimiters(simultaneous)

      [
        name,
        opening,
        Enum.map(contents, &@protocol.to_string/1),
        closing
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")
    end

    def delimiters(true), do: {"<<", ">>"}
    def delimiters(false), do: {"{", "}"}
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{name: name} = voice, _opts) do
      concat([
        "#Satie.Score<",
        if(name, do: name <> " ", else: ""),
        inspect_contents(voice),
        ">"
      ])
    end

    def inspect_contents(%@for{simultaneous: simultaneous, contents: contents}) do
      {open, close} = delimiters(simultaneous)
      open <> "#{length(contents)}" <> close
    end

    def delimiters(true), do: {"<<", ">>"}
    def delimiters(false), do: {"{", "}"}
  end

  defimpl Satie.ToLilypond do
    import Satie.Lilypond.OutputHelpers

    def to_lilypond(%@for{contents: contents} = voice) do
      {opening, closing} = delimiters(voice)

      [
        opening,
        format_contents(contents),
        closing
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")
    end

    defp delimiters(%@for{name: name, simultaneous: simultaneous}) do
      {open, close} = delimiters_for_simultaneous(simultaneous)
      name = context_signature("Score", name)
      {name <> " " <> open, close}
    end
  end
end
