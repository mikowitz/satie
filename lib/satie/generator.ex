defmodule Satie.Generator do
  @moduledoc """
    Shared functionality for generators
  """
  defmacro __using__(_) do
    quote do
      import Satie.Generators.GeneratorHelpers

      defimpl Satie.ToLilypond do
        def to_lilypond(generator, options) do
          generator
          |> generator.__struct__.generate()
          |> @protocol.to_lilypond(options)
        end
      end
    end
  end
end
