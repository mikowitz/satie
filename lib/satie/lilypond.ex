defmodule Satie.Lilypond do
  @moduledoc false

  if Version.compare(System.version(), "1.10.0") == :lt do
    # credo:disable-for-lines:2 Credo.Check.Warning.ApplicationConfigInModuleAttribute
    @runner Application.get_env(:satie, :runner)
    @lilypond_version Application.get_env(:satie, :lilypond_version)
  else
    @runner Application.compile_env(:satie, :runner)
    @lilypond_version Application.compile_env(:satie, :lilypond_version)
  end

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
    with command <- to_charlist(command) do
      @runner.(command) |> to_string
    end
  end
end
