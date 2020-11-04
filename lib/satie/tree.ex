defmodule Satie.Tree do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      defstruct [unquote_splicing(opts), :id, :music]

      use Satie.Access
    end
  end
end
