use Mix.Config

config :mix_test_watch,
  tasks: [
    "coveralls.html",
    "format",
    "credo --strict"
  ]

config :satie, :runner, &IO.puts/1
config :satie, :lilypond_version, "2.20.0"
