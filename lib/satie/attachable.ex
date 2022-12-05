defmodule Satie.Attachable do
  defmacro __using__(opts) do
    location = Keyword.get(opts, :location, :after)
    priority = Keyword.get(opts, :priority, 0)
    has_direction = Keyword.get(opts, :has_direction, true)

    quote do
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
