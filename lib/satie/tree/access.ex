defmodule Satie.Tree.Access do
  defmacro __using__(_) do
    quote do
      @behaviour Access

      def fetch(%__MODULE__{contents: contents}, key) do
        case find(contents, key) do
          nil -> :error
          value -> {:ok, value}
        end
      end

      def get_and_update(%__MODULE__{contents: contents} = container, key, func) do
        case fetch(container, key) do
          :error ->
            {nil, container}

          {:ok, current} ->
            index = find_index(contents, key)

            case func.(current) do
              {get, update} ->
                new_contents = List.replace_at(contents, index, update)
                {get, %{container | contents: new_contents}}

              :pop ->
                new_contents = List.delete_at(contents, index)
                {current, %{container | contents: new_contents}}
            end
        end
      end

      def pop(%__MODULE__{contents: contents} = container, key) do
        case fetch(container, key) do
          :error ->
            {nil, container}

          {:ok, current} ->
            index = find_index(contents, key)
            new_contents = List.delete_at(contents, index)
            {current, %{container | contents: new_contents}}
        end
      end

      defp find(contents, index) when is_integer(index), do: Enum.at(contents, index)

      defp find(contents, name) when is_bitstring(name) do
        Enum.find(contents, fn
          %{name: ^name} -> true
          _ -> false
        end)
      end

      defp find_index(_contents, index) when is_integer(index), do: index

      defp find_index(contents, name) when is_bitstring(name) do
        Enum.find_index(contents, fn
          %{name: ^name} -> true
          _ -> false
        end)
      end
    end
  end
end
