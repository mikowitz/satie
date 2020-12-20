defmodule Satie.Tree do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      defstruct [unquote_splicing(opts), :id, :music]

      alias __MODULE__
      alias Satie.Lilypond.Parser
      use Satie.Access

      def new(lilypond_string) when is_bitstring(lilypond_string) do
        with {:ok, tree} <- Parser.parse(lilypond_string) do
          case __MODULE__ do
            Satie.Voice -> Satie.Voice.new(tree.music)
            _ -> tree
          end
        end
      end
    end
  end
end
