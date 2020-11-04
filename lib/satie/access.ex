defmodule Satie.Access do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      @behaviour Access

      def get(%__MODULE__{} = tree, key, default \\ nil) do
        case fetch(tree, key) do
          :error -> default
          {:ok, value} -> value
        end
      end

      @impl Access
      def fetch(%__MODULE__{music: music}, key) when is_number(key) do
        case Enum.at(music, key) do
          nil -> :error
          value -> {:ok, value}
        end
      end

      def fetch(%__MODULE__{music: music}, key) when is_reference(key) do
        case Enum.find(music, fn %{id: id} -> id === key end) do
          nil -> :error
          value -> {:ok, value}
        end
      end

      def fetch(%__MODULE__{music: music}, key) when is_bitstring(key) do
        case Enum.find(music, fn %{name: name} -> name === key end) do
          nil -> :error
          value -> {:ok, value}
        end
      end

      def fetch(%__MODULE__{} = tree, %{id: id}) do
        fetch(tree, id)
      end

      @impl Access
      def get_and_update(%__MODULE__{music: music} = tree, key, func) when is_number(key) do
        case fetch(tree, key) do
          :error ->
            {nil, tree}

          {:ok, value} ->
            case func.(value) do
              {get, update} ->
                {get, %{tree | music: List.replace_at(music, key, update)}}

              :pop ->
                {value, %{tree | music: List.delete_at(music, key)}}
            end
        end
      end

      def get_and_update(%__MODULE__{} = tree, %{id: id}, func) do
        get_and_update(tree, id, func)
      end

      def get_and_update(%__MODULE__{music: music} = tree, key, func) do
        case fetch(tree, key) do
          :error ->
            {nil, tree}

          {:ok, value} ->
            get_and_update(tree, Enum.find_index(music, fn x -> x == value end), func)
        end
      end

      @impl Access
      def pop(%__MODULE__{music: music} = tree, key) when is_number(key) do
        case fetch(tree, key) do
          :error ->
            {nil, tree}

          {:ok, value} ->
            {value, %{tree | music: List.delete_at(music, key)}}
        end
      end

      def pop(%__MODULE__{} = tree, %{id: id}) do
        pop(tree, id)
      end

      def pop(%__MODULE__{music: music} = tree, key) do
        case fetch(tree, key) do
          :error ->
            {nil, tree}

          {:ok, value} ->
            pop(tree, Enum.find_index(music, fn x -> x == value end))
        end
      end
    end
  end
end
