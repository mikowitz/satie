defmodule SatieTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Satie.Note

  describe "show/1" do
    test "returns an error if the input is not a lilypondable object" do
      assert Satie.show(3) == {:error, "3 cannot be formatted in Lilypond"}
    end

    test "calls the configured lilypond runner if the input is a lilypondable object" do
      note = Note.new("c'4")

      output =
        capture_io(fn ->
          file = Satie.show(note)

          {:ok, lilypond} = File.read(file.source_path)

          assert lilypond ==
                   """
                   \\version "#{Satie.lilypond_version()}"
                   \\language "english"

                   {
                     c'4
                   }
                   """
                   |> String.trim()

          :ok = File.rm(file.source_path)
        end)

      assert Regex.match?(~r/#{Satie.lilypond_executable()} -o (.*) \1\.ly\nopen \1\.pdf/, output)
    end
  end
end
