defmodule Satie.Guards do
  @moduledoc """
    Implements custom guard macros
  """

  defguard is_integer_duple(value)
           when is_tuple(value) and
                  tuple_size(value) == 2 and
                  is_integer(elem(value, 0)) and is_integer(elem(value, 1))

  defguard is_integer_duple_input(value) when is_integer(value) or is_integer_duple(value)

  defguard is_fractional(value)
           when is_map(value) and
                  is_map_key(value, :numerator) and
                  is_map_key(value, :denominator)
end
