use Mix.Config

config :satie, :runner, &:os.cmd/1

system_result = :os.cmd('lilypond -v')
[[version] | _] = Regex.scan(~r/[\d.]+/, to_string(system_result))
config :satie, :lilypond_version, version
