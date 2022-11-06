defmodule Satie.TupletTest do
  use ExUnit.Case, async: true

  alias Satie.{Container, Multiplier, Note, Rest, Tuplet}

  describe inspect(&Tuplet.new/2) do
    test "takes a multiplier and contents" do
      tuplet =
        Tuplet.new(
          Multiplier.new(2, 3),
          [Note.new("c'4"), Rest.new("r4"), Note.new("d'4")]
        )

      assert is_struct(tuplet, Tuplet)
    end

    test "returns an error tuple if any of the contents are not Lilypond-able" do
      assert Tuplet.new(
               Multiplier.new(2, 3),
               [Note, Rest.new("r4"), Note.new("d'4")]
             ) == {:error, :tuplet_new, [Note]}
    end

    test "can be initialized with a multiplier tuple" do
      tuplet =
        Tuplet.new(
          {2, 3},
          [Note.new("c'4"), Rest.new("r4"), Note.new("d'4")]
        )

      assert tuplet.multiplier == Multiplier.new(2, 3)
    end
  end

  describe inspect(&String.Chars.to_string/1) do
    test "returns a simple string output of the tuplet" do
      tuplet =
        Tuplet.new({2, 3}, [
          Note.new("c'4"),
          Note.new("d'4"),
          Note.new("ef'4")
        ])

      assert to_string(tuplet) == "3/2 { c'4 d'4 ef'4 }"
    end

    test "works for nested tuplets" do
      tuplet =
        Tuplet.new({5, 3}, [
          Tuplet.new({2, 3}, [
            Note.new("c'4"),
            Note.new("d'4"),
            Note.new("ef'4")
          ]),
          Rest.new("r4")
        ])

      assert to_string(tuplet) == "3/5 { 3/2 { c'4 d'4 ef'4 } r4 }"
    end
  end

  describe inspect(&Inspect.inspect/2) do
    test "returns a tuplet formatted for IEx" do
      tuplet =
        Tuplet.new({2, 3}, [
          Note.new("c'4"),
          Note.new("d'4"),
          Note.new("ef'4")
        ])

      assert inspect(tuplet) == "#Satie.Tuplet<3/2 { c'4 d'4 ef'4 }>"
    end

    test "works for nested tuplets" do
      tuplet =
        Tuplet.new({5, 3}, [
          Tuplet.new({2, 3}, [
            Note.new("c'4"),
            Note.new("d'4"),
            Note.new("ef'4")
          ]),
          Rest.new("r4")
        ])

      assert inspect(tuplet) == "#Satie.Tuplet<3/5 { 3/2 { c'4 d'4 ef'4 } r4 }>"
    end
  end

  describe inspect(&Satie.ToLilypond.to_lilypond/1) do
    test "returns valid Lilypond output for a tuplet" do
      tuplet =
        Tuplet.new({2, 3}, [
          Note.new("c'4"),
          Note.new("d'4"),
          Note.new("ef'4")
        ])

      assert Satie.to_lilypond(tuplet) ==
               """
               \\tuplet 3/2 {
                 c'4
                 d'4
                 ef'4
               }
               """
               |> String.trim()
    end

    test "returns valid Lilypond output for nested tuplets" do
      tuplet =
        Tuplet.new({5, 3}, [
          Tuplet.new({2, 3}, [
            Note.new("c'4"),
            Note.new("d'4"),
            Note.new("ef'4")
          ]),
          Rest.new("r4")
        ])

      assert Satie.to_lilypond(tuplet) ==
               """
               \\tuplet 3/5 {
                 \\tuplet 3/2 {
                   c'4
                   d'4
                   ef'4
                 }
                 r4
               }
               """
               |> String.trim()
    end
  end

  describe "Enumerable" do
    setup do
      tuplet =
        Tuplet.new({5, 3}, [
          Tuplet.new({2, 3}, [
            Note.new("c'4"),
            Note.new("d'4"),
            Note.new("ef'4")
          ]),
          Rest.new("r4")
        ])

      {:ok, tuplet: tuplet}
    end

    test "responds to length", %{tuplet: tuplet} do
      assert Enum.count(tuplet) == 2
      assert Enum.count(tuplet[0]) == 3
    end

    test "can test membership", %{tuplet: tuplet} do
      assert Rest.new("r4") in tuplet
    end

    test "can be reduced", %{tuplet: tuplet} do
      assert Enum.reduce(tuplet[0], "", fn note, acc ->
               acc <> to_string(note)
             end) == "c'4d'4ef'4"
    end

    test "can be reduced using another Satie tree", %{tuplet: tuplet} do
      assert Enum.reduce(tuplet[0], Container.new([]), fn note, acc ->
               Satie.append(acc, note)
             end) ==
               Container.new([
                 Note.new("c'4"),
                 Note.new("d'4"),
                 Note.new("ef'4")
               ])
    end

    test "can return a sliced set of contents", %{tuplet: tuplet} do
      assert Enum.slice(tuplet[0], 0, 2) == [
               Note.new("c'4"),
               Note.new("d'4")
             ]
    end

    test "can slice beyond bounds", %{tuplet: tuplet} do
      assert Enum.slice(tuplet, 1, 10) == [Rest.new("r4")]
    end
  end
end
