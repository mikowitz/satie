defmodule Satie.StringHelpers do
  def position_indicator(:neutral), do: "-"
  def position_indicator(:up), do: "^"
  def position_indicator(:down), do: "_"
end
