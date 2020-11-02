defmodule Satie.Access do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      @behaviour Access

      def get(%__MODULE__{} = container, key, default \\ nil) do
        case fetch(container, key) do
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

      def fetch(%__MODULE__{} = container, %{id: id}) do
        fetch(container, id)
      end

      @impl Access
      def get_and_update(%__MODULE__{music: music} = container, key, func) when is_number(key) do
        case fetch(container, key) do
          :error ->
            {nil, container}

          {:ok, value} ->
            case func.(value) do
              {get, update} ->
                {get, %{container | music: List.replace_at(music, key, update)}}

              :pop ->
                {value, %{container | music: List.delete_at(music, key)}}
            end
        end
      end

      def get_and_update(%__MODULE__{} = container, %{id: id}, func) do
        get_and_update(container, id, func)
      end

      def get_and_update(%__MODULE__{music: music} = container, key, func) do
        case fetch(container, key) do
          :error ->
            {nil, container}

          {:ok, value} ->
            get_and_update(container, Enum.find_index(music, fn x -> x == value end), func)
        end
      end

      @impl Access
      def pop(%__MODULE__{music: music} = container, key) when is_number(key) do
        case fetch(container, key) do
          :error ->
            {nil, container}

          {:ok, value} ->
            {value, %{container | music: List.delete_at(music, key)}}
        end
      end

      def pop(%__MODULE__{} = container, %{id: id}) do
        pop(container, id)
      end

      def pop(%__MODULE__{music: music} = container, key) do
        case fetch(container, key) do
          :error ->
            {nil, container}

          {:ok, value} ->
            pop(container, Enum.find_index(music, fn x -> x == value end))
        end
      end
    end
  end
end
