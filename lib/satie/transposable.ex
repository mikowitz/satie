defmodule Satie.Transposable do
  defmacro __using__(struct_key, _opts \\ []) do
    quote do
      def transpose(%__MODULE__{} = mod, %Satie.Interval{} = interval) do
        Map.update(mod, unquote(struct_key), nil, fn el ->
          case is_list(el) do
            true -> Enum.map(el, &Satie.transpose(&1, interval))
            false -> Satie.transpose(el, interval)
          end
        end)
      end

      def invert(%__MODULE__{} = mod, %Satie.Pitch{} = axis) do
        Map.update(mod, unquote(struct_key), nil, fn el ->
          case is_list(el) do
            true -> Enum.map(el, &Satie.invert(&1, axis))
            false -> Satie.invert(el, axis)
          end
        end)
      end
    end
  end
end
