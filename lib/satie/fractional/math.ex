defmodule Satie.Fractional.Math do
  @moduledoc """
    Models common arithmetic functions between fractional types
  """

  defmacro __using__(conversions) do
    quote do
      alias Satie.Fractional
      import Satie.Guards

      def add(%__MODULE__{} = fraction, %rhs_struct{} = rhs) when is_fractional(rhs) do
        {n1, d1} = Fractional.to_tuple(fraction)
        {n2, d2} = Fractional.to_tuple(rhs)

        return_struct = find_return_struct(:add, rhs_struct)
        return_struct.new(n1 * d2 + n2 * d1, d1 * d2)
      end

      def subtract(%__MODULE__{} = fraction, %rhs_struct{} = rhs) when is_fractional(rhs) do
        {n1, d1} = Fractional.to_tuple(fraction)
        {n2, d2} = Fractional.to_tuple(rhs)

        return_struct = find_return_struct(:subtract, rhs_struct)
        return_struct.new(n1 * d2 - n2 * d1, d1 * d2)
      end

      def multiply(%__MODULE__{} = fraction, %rhs_struct{} = rhs) when is_fractional(rhs) do
        {n1, d1} = Fractional.to_tuple(fraction)
        {n2, d2} = Fractional.to_tuple(rhs)

        return_struct = find_return_struct(:multiply, rhs_struct)
        return_struct.new(n1 * n2, d1 * d2)
      end

      def multiply(%__MODULE__{} = fraction, rhs) when is_integer(rhs) do
        {n, d} = Fractional.to_tuple(fraction)
        new(n * rhs, d)
      end

      def divide(%__MODULE__{} = fraction, %rhs_struct{} = rhs) when is_fractional(rhs) do
        {n1, d1} = Fractional.to_tuple(fraction)
        {n2, d2} = Fractional.to_tuple(rhs)

        return_struct = find_return_struct(:divide, rhs_struct)
        return_struct.new(n1 * d2, n2 * d1)
      end

      def divide(%__MODULE__{} = fraction, rhs) when is_integer(rhs) and rhs != 0 do
        {n, d} = Fractional.to_tuple(fraction)
        new(n, d * rhs)
      end

      defp find_return_struct(key, rhs_struct) do
        unquote(conversions)
        |> Keyword.get(key, [])
        |> Enum.find({__MODULE__, __MODULE__}, fn {src, _} -> src == rhs_struct end)
        |> elem(1)
      end
    end
  end
end
