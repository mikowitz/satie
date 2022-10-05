defmodule Satie.Helpers do
  def normalize_size(size) when size > 7, do: normalize_size(size - 7)
  def normalize_size(size), do: size

  def polarity_to_string(-1), do: "-"
  def polarity_to_string(1), do: "+"
  def polarity_to_string(0), do: ""

  def quartertone_string_to_number(""), do: 0.0
  def quartertone_string_to_number("+"), do: 0.5
  def quartertone_string_to_number("~"), do: -0.5

  def sign(n) when n == 0, do: 0
  def sign(n) when n > 0, do: 1
  def sign(n) when n < 0, do: -1
end
