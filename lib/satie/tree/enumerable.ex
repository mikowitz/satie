defmodule Satie.Tree.Enumerable do
  @moduledoc """
  Implements the `Enumerable` protocol for tree-like score elements
  """
  defmacro __using__(_) do
    quote do
      defimpl Enumerable do
        def count(%@for{contents: contents}), do: {:ok, length(contents)}

        def member?(%@for{contents: contents}, elem), do: {:ok, elem in contents}

        def reduce(%@for{} = _tree, {:halt, acc}, _fun), do: {:halted, acc}

        def reduce(%@for{} = tree, {:suspend, acc}, fun),
          do: {:suspended, acc, &reduce(tree, &1, fun)}

        def reduce(%@for{contents: []}, {:cont, acc}, _fun), do: {:done, acc}

        def reduce(%@for{contents: [head | tail]} = tree, {:cont, acc}, fun) do
          reduce(%@for{tree | contents: tail}, fun.(head, acc), fun)
        end

        if Version.compare(System.version(), "1.14.0") == :lt do
          def slice(%@for{contents: contents} = tree) do
            {:ok, len} = count(tree)
            {:ok, len, &Enumerable.List.slice(contents, &1, &2, len)}
          end
        else
          def slice(%@for{contents: contents} = tree) do
            {:ok, len} = count(tree)
            {:ok, len, & &1.contents}
          end
        end
      end
    end
  end
end
