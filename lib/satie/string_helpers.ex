defmodule Satie.StringHelpers do
  def direction_indicator(nil), do: "-"
  def direction_indicator(:up), do: "^"
  def direction_indicator(:down), do: "_"
end
