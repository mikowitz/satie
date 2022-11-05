import Config

lilypond_executable =
  case System.cmd("which", ~w(lilypond)) do
    {"", 1} -> nil
    {lilypond, 0} -> String.trim(lilypond)
  end

lilypond_version =
  case lilypond_executable do
    nil ->
      nil

    lilypond_exec ->
      {ly_version_output, 0} = System.cmd(lilypond_exec, ~w(--version))
      [[version] | _] = Regex.scan(~r/[\d.]+/, to_string(ly_version_output))
      version
  end

config :satie,
  lilypond_executable: lilypond_executable,
  lilypond_version: lilypond_version,
  temp_directory: Path.expand("~/.satie")

import_config "#{Mix.env()}.exs"
