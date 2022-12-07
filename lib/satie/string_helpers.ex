defmodule Satie.StringHelpers do
  @moduledoc """
  Helper functions for implementing `String.Chars`
  """

  def direction_indicator(nil), do: "-"
  def direction_indicator(:up), do: "^"
  def direction_indicator(:down), do: "_"
end
