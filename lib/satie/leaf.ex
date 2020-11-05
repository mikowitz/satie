defmodule Satie.Leaf do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      alias __MODULE__
      alias Satie.Duration
      alias Satie.Lilypond.Parser

      defstruct [unquote_splicing(opts), :id, attachments: [], spanners: []]

      def new(lilypond_string) when is_bitstring(lilypond_string) do
        with {:ok, %__MODULE__{} = leaf} <- Parser.parse(lilypond_string), do: leaf
      end

      defp raise_unassignable_duration_error(%Duration{numerator: n, denominator: d}) do
        raise Satie.UnassignableDurationError,
          message: "Duration<#{n}, #{d}> is unassignable"
      end
    end
  end
end
