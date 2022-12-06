defmodule Satie.Tree.Collectable do
  @moduledoc """
  Implements the `Collectable` protocol for tree elements of a score
  """
  defmacro __using__(_) do
    quote do
      defimpl Collectable do
        def into(%@for{} = tree) do
          fun = fn
            tree, {:cont, elem} ->
              Satie.append(tree, elem)

            tree, :done ->
              tree

            _tree, :halt ->
              :ok
          end

          {tree, fun}
        end
      end
    end
  end
end
