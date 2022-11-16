defmodule Satie.Leaf do
  defmacro __using__(fields) do
    quote do
      defstruct [unquote_splicing(fields), :written_duration, attachments: []]
    end
  end
end
