defmodule Satie.Tree do
  defmacro __using__(_) do
    quote do
      use Satie.Tree.Access
      use Satie.Tree.Enumerable
      use Satie.Tree.Collectable
    end
  end
end
