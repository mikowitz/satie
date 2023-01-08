defmodule Satie.Fractional.Comparison do
  @moduledoc """
  Models comparison between fractional types
  """

  defmacro __using__(_) do
    quote do
      def eq(%__MODULE__{} = fractional1, %__MODULE__{} = fractional2) do
        to_float(fractional1) == to_float(fractional2)
      end

      def gt(%__MODULE__{} = fractional1, %__MODULE__{} = fractional2) do
        to_float(fractional1) > to_float(fractional2)
      end

      def gte(%__MODULE__{} = fractional1, %__MODULE__{} = fractional2) do
        to_float(fractional1) >= to_float(fractional2)
      end

      def lt(%__MODULE__{} = fractional1, %__MODULE__{} = fractional2) do
        to_float(fractional1) < to_float(fractional2)
      end

      def lte(%__MODULE__{} = fractional1, %__MODULE__{} = fractional2) do
        to_float(fractional1) <= to_float(fractional2)
      end
    end
  end
end
