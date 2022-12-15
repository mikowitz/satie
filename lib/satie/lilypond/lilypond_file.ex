defmodule Satie.Lilypond.LilypondFile do
  @moduledoc """
  Implements constructing a lilypond file from a score-level element input
  """
  defstruct [:content, :lilypond_options, :source_path, :output_path]

  @satie_temp_directory Application.compile_env!(:satie, :temp_directory)
  File.mkdir_p!(@satie_temp_directory)

  @runner Application.compile_env!(:satie, :lilypond_runner)

  def from(content, lilypond_options \\ [])

  def from(%{contents: _} = container, lilypond_options) do
    %__MODULE__{content: container, lilypond_options: lilypond_options}
  end

  def from(%Satie.Timespan{} = timespan, lilypond_options) do
    %__MODULE__{content: timespan, lilypond_options: lilypond_options}
  end

  def from(%Satie.TimespanList{} = timespan, lilypond_options) do
    %__MODULE__{content: timespan, lilypond_options: lilypond_options}
  end

  def from(leaf, lilypond_options) do
    Satie.Container.new([leaf])
    |> from(lilypond_options)
  end

  def save(
        %__MODULE__{content: content, lilypond_options: lilypond_options} = file,
        source_path \\ construct_filepath()
      ) do
    file_contents = build_contents(content, lilypond_options)

    File.mkdir_p!(Path.dirname(source_path))
    :ok = File.write(source_path, file_contents)

    %__MODULE__{file | source_path: source_path}
  end

  def show(%__MODULE__{} = file) do
    %__MODULE__{source_path: source_path} = file = save(file)

    output_location = Path.rootname(source_path)

    run("#{Satie.lilypond_executable()} -o #{output_location} #{source_path}")
    run("open #{output_location}.pdf")

    %{file | output_path: output_location <> ".pdf"}
  end

  defp run(command) do
    command |> to_charlist() |> @runner.()
  end

  defp build_contents(content, lilypond_options) do
    [
      ~s(\\version "#{Satie.lilypond_version()}"),
      ~s(\\language "english"),
      "",
      Satie.to_lilypond(content, lilypond_options)
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp construct_filepath do
    [
      DateTime.utc_now() |> Calendar.strftime("%Y-%m-%d-%H-%M-%S"),
      "-",
      :erlang.system_time(),
      ".ly"
    ]
    |> Enum.join("")
    |> then(&Path.join(@satie_temp_directory, &1))
  end
end
