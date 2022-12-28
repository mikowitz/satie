defmodule Satie.FermataTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Fermata, Rest}

  doctest Fermata

  describe_function &Fermata.new/1 do
    test "returns the correct components" do
      assert Fermata.new(:verylong) == %Fermata{
               length: :verylong,
               components: [
                 after: [
                   "\\verylongfermata"
                 ]
               ]
             }
    end
  end

  describe "attaching a fermata to a rest" do
    test "returns the correct lilypond" do
      rest =
        Rest.new("4")
        |> Satie.attach(Fermata.new(:short), direction: :down)

      assert Satie.to_lilypond(rest) ==
               """
               r4
                 _ \\shortfermata
               """
               |> String.trim()
    end
  end
end
