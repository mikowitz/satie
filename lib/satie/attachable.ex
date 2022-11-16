defmodule Satie.Attachable do
  defmacro __using__(opts) do
    location = Keyword.get(opts, :location, :after)
    priority = Keyword.get(opts, :priority, 0)

    quote do
      defimpl Satie.IsAttachable do
        def attachable?(_), do: true

        def location(_), do: unquote(location)

        def priority(_), do: unquote(priority)
      end
    end
  end
end
