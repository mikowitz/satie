defmodule Satie.Duration do
  defstruct [:numerator, :denominator]

  require Bitwise

  @doc """

    iex> Duration.new(1, 8)
    %Duration{
      numerator: 1,
      denominator: 8
    }

    iex> Duration.new(4, 16)
    %Duration{
      numerator: 1,
      denominator: 4
    }

  """
  def new(numerator \\ 1, denominator \\ 4) do
    with {n, d} <- reduce(numerator, denominator) do
      %__MODULE__{
        numerator: n,
        denominator: d
      }
    end
  end

  def assignable?(%__MODULE__{} = duration) do
    [&proper_length?/1, &proper_subdivision?/1, &not_tied?/1]
    |> Enum.all?(fn func -> func.(duration) end)
  end

  ## PRIVATE ##

  defp proper_length?(%__MODULE__{numerator: n, denominator: d}) do
    with l <- n / d do
      0 < l and l < 2
    end
  end

  defp proper_subdivision?(%__MODULE__{denominator: d}) do
    Bitwise.band(d, d-1) == 0
  end

  defp not_tied?(%__MODULE__{numerator: n}) do
    n |> Integer.to_string(2) |> String.match?(~r/01/) |> Kernel.!()
  end

  defp reduce(a, b) do
    with g <- Integer.gcd(a, b) do
      { round(a / g), round(b / g) }
    end
  end
end

defimpl Satie.ToLilypond, for: Satie.Duration do
  alias Satie.Duration

  def to_lilypond(%Duration{numerator: n, denominator: d} = duration) do
    with true <- Satie.Duration.assignable?(duration) do
      base_duration_string(duration) <> String.duplicate(".", dots_count(duration))
    else
      false -> raise Satie.UnassignableDurationError,
        message: "Duration<#{n}, #{d}> is unengraveable"
    end
  end

  defp dots_count(%Duration{numerator: n}) do
    with b <- Integer.to_string(n, 2) do
      Regex.scan(~r/1/, b) |> length |> Kernel.-(1)
    end
  end

  defp base_duration_string(%Duration{denominator: d} = duration) do
    :math.pow(2, :math.log2(d) - dots_count(duration)) |> round |> to_string
  end
end
