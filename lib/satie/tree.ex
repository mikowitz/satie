defmodule Satie.Tree do
  @moduledoc """
    Implements shared behaviour for tree elements of a score

    * Container
    * Tuplet
    * Measure
    * Voice
    * Staff
    * StaffGroup
    * Score
  """

  defmacro __using__(_) do
    quote do
      use Satie.Tree.Access
      use Satie.Tree.Enumerable
      use Satie.Tree.Collectable
    end
  end
end
