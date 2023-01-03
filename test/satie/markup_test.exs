defmodule Satie.MarkupTest do
  use ExUnit.Case, async: true
  import DescribeFunction

  alias Satie.{Markup, Note}

  describe_function &Markup.new/1 do
    test "can build a simple text markup" do
      component =
        """
        \\markup {
          hello
        }
        """
        |> String.trim()

      assert Markup.new("hello") == %Markup{
               content: "hello",
               components: [
                 after: [component]
               ]
             }
    end

    test "more complex nested markup can be built up" do
      markup =
        "hello"
        |> Markup.italic()
        |> Markup.new()

      component =
        """
        \\markup {
          \\italic {
            "hello"
          }
        }
        """
        |> String.trim()

      assert markup == %Markup{
               content: %{
                 command: "italic",
                 content: "hello"
               },
               components: [
                 after: [component]
               ]
             }
    end

    test "some markup can take arguments" do
      markup =
        "hello"
        |> Markup.fontsize(23)
        |> Markup.new()

      component =
        """
        \\markup {
          \\fontsize #23 {
            "hello"
          }
        }
        """
        |> String.trim()

      assert markup == %Markup{
               content: %{
                 command: "fontsize",
                 argument: 23,
                 overrides: [],
                 content: "hello"
               },
               components: [
                 after: [component]
               ]
             }
    end

    test "some markup takes overrides" do
      markup =
        "hello"
        |> Markup.box(box_padding: 3, thickness: 5)
        |> Markup.new()

      component =
        """
        \\markup {
          \\override #'(
            (box-padding . 3)
            (thickness . 5)
          )
          \\box {
            "hello"
          }
        }
        """
        |> String.trim()

      assert markup == %Markup{
               content: %{
                 command: "box",
                 overrides: %{"box-padding" => 3, "thickness" => 5},
                 content: "hello"
               },
               components: [after: [component]]
             }
    end

    test "some markup can take a list of contents" do
      markup =
        Markup.column([
          Markup.italic("hello"),
          Markup.bold("hi")
        ])
        |> Markup.new()

      component =
        """
        \\markup {
          \\column {
            \\italic {
              "hello"
            }
            \\bold {
              "hi"
            }
          }
        }
        """
        |> String.trim()

      assert markup == %Markup{
               content: %{
                 command: "column",
                 content: [
                   %{command: "italic", content: "hello"},
                   %{command: "bold", content: "hi"}
                 ]
               },
               components: [after: [component]]
             }
    end
  end

  describe_function &Markup.italic/1 do
    test "returns the correct data map" do
      assert Markup.italic("ok") == %{
               command: "italic",
               content: "ok"
             }
    end
  end

  describe_function &Markup.fontsize/2 do
    test "returns the correct data map" do
      assert Markup.fontsize("ok", 15) == %{
               command: "fontsize",
               overrides: [],
               argument: 15,
               content: "ok"
             }
    end
  end

  describe_function &Markup.box/2 do
    test "returns the correct data map" do
      assert Markup.box("ok") == %{
               command: "box",
               overrides: [],
               content: "ok"
             }

      assert Markup.box("ok", box_padding: 3) == %{
               command: "box",
               overrides: %{
                 "box-padding" => 3
               },
               content: "ok"
             }
    end
  end

  describe "attaching markup to a note" do
    test "returns the correct lilypond" do
      markup =
        "hello"
        |> Markup.italic()
        |> Markup.new()

      note =
        Note.new("c4")
        |> Satie.attach(markup, direction: :up)

      assert Satie.to_lilypond(note) ==
               """
               c4
                 ^ \\markup {
                   \\italic {
                     "hello"
                   }
                 }
               """
               |> String.trim()
    end
  end
end
