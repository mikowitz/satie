defmodule Satie.Attachable do
  @moduledoc """
    Implements shared behaviour for objects that can be attached to score-level elements

    * articulations
    * clefs
    * time signatures
    * key signatures
    * slurs
    * beams
    * dynamics
    * etc.
  """
  defmacro __using__(opts) do
    location = Keyword.get(opts, :location, :after)
    priority = Keyword.get(opts, :priority, 0)
    fields = Keyword.get(opts, :fields, [])
    has_direction = Keyword.get(opts, :has_direction, true)

    quote do
      defstruct [unquote_splicing(fields), :components]

      defimpl Satie.IsAttachable do
        def attachable?(_), do: true

        def location(_), do: unquote(location)

        def priority(_), do: unquote(priority)
      end

      defimpl Satie.HasDirection do
        def has_direction?(_), do: unquote(has_direction)
      end
    end
  end
end
