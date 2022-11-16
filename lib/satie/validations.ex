defmodule Satie.Validations do
  @valid_positions ~w(neutral up down)a
  def validate_position(position) when position in @valid_positions do
    position
  end

  def validate_position(_), do: :neutral
end
