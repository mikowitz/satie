defmodule Satie.Leaf do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      alias Satie.Duration

      defstruct [unquote_splicing(opts), :id, attachments: [], spanners: []]

      defp raise_unassignable_duration_error(%Duration{numerator: n, denominator: d}) do
        raise Satie.UnassignableDurationError,
          message: "Duration<#{n}, #{d}> is unassignable"
      end
    end
  end
end
