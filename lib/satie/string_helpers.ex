defmodule Satie.StringHelpers do
  @moduledoc false

  def direction_indicator(nil), do: "-"
  def direction_indicator(:up), do: "^"
  def direction_indicator(:down), do: "_"
end
