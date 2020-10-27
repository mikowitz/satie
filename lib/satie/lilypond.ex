defmodule Satie.Lilypond do
  @moduledoc false

  {system_result, 0} = System.cmd("lilypond", ["-v"])
  [[version] | _] = Regex.scan(~r/[\d.]+/, system_result)
  @lilypond_version version

  def lilypond_version, do: @lilypond_version

  def show(music) do
    with {:ok, filename} <- save(music) do
      output_location = Path.rootname(filename)
      run("lilypond -o #{output_location} #{filename}")
      run("open #{output_location}.pdf")
    end
  end

  def save(music, filename \\ nil) do
    with filename <- resolve_filename(filename),
         content <- build_contents(music) do
      File.write(filename, content)
      {:ok, filename}
    end
  end

  defp resolve_filename(nil), do: "/tmp/#{:erlang.system_time()}.ly"
  defp resolve_filename(filename) when is_bitstring(filename), do: filename

  defp build_contents(%{music: _} = music) do
    [
      ~s(\\version "#{@lilypond_version}"),
      ~s(\\language "english"),
      "",
      Satie.to_lilypond(music)
    ]
    |> Enum.join("\n")
  end

  defp build_contents(leaf) do
    [
      ~s(\\version "#{@lilypond_version}"),
      ~s(\\language "english"),
      "",
      "{",
      "  " <> Satie.to_lilypond(leaf),
      "}"
    ]
    |> Enum.join("\n")
  end

  defp run(command) do
    command |> to_charlist |> :os.cmd() |> to_string
  end
end
