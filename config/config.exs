use Mix.Config

if Mix.env() == :dev do
  config :mix_test_watch,
    tasks: [
      "test",
      "format",
      "coveralls.html",
      "credo --strict"
    ]
end
