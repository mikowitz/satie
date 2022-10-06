defmodule Satie.RegressionDataStreamer do
  require Logger

  def begin_download(url) do
    {:ok, _status, _headers, client} = :hackney.get(url)
    client
  end

  def continue_download(client) do
    case :hackney.stream_body(client) do
      {:ok, data} ->
        {[data], client}

      :done ->
        {:halt, client}

      {:error, reason} ->
        raise reason
    end
  end

  def finish_download(client) do
    :hackney.close(client)
  end

  def fetch(module, function) do
    url =
      "https://raw.githubusercontent.com/mikowitz/satie_regression_data/main/data/#{module}/#{function}.txt"

    Stream.resource(
      fn -> begin_download(url) end,
      &continue_download/1,
      &finish_download/1
    )
    |> Stream.concat([:end])
    |> Stream.transform("", fn
      :end, prev ->
        {[prev], ""}

      chunk, prev ->
        [last_line | lines] =
          String.split(prev <> chunk, "\n")
          |> Enum.reverse()

        {Enum.reverse(lines), last_line}
    end)
  end

  defmacro regression_test(module, function, assert_function) do
    quote do
      @tag :regression
      @tag timeout: :infinity
      test "regression_test: #{unquote(module)}/#{unquote(function)}" do
        Satie.RegressionDataStreamer.fetch(unquote(module), unquote(function))
        |> Stream.reject(&(&1 == ""))
        |> Stream.map(&String.split(&1, ":"))
        |> Stream.map(unquote(assert_function))
        |> Enum.to_list()
      end
    end
  end
end
