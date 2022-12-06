defmodule Satie.Leaf do
  @moduledoc """
    Models shared behaviour for leaf elements of a score

    * Note
    * Chord
    * Leaf
    * Spacer

  """
  defmacro __using__(fields) do
    quote do
      defstruct [unquote_splicing(fields), :written_duration, attachments: []]
    end
  end
end
