import Config

config :satie,
  lilypond_runner: &IO.puts/1

config :mix_test_watch,
  extra_extensions: [".ly", ".ily"],
  tasks: [
    "test",
    "credo --all --strict"
  ]
