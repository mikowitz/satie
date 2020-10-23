defmodule SatieTest do
  use ExUnit.Case
  doctest Satie

  test "greets the world" do
    assert Satie.hello() == :world
  end
end
