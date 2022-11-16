defmodule Satie.LaissezVibrer do
  defstruct [:position]

  use Satie.Attachable

  import Satie.Validations

  @doc """

      iex> LaissezVibrer.new()
      #Satie.LaissezVibrer<>

      iex> LaissezVibrer.new(:up)
      #Satie.LaissezVibrer<up>

      iex> LaissezVibrer.new(:something_else)
      #Satie.LaissezVibrer<>

  """
  def new(position \\ :neutral) do
    with position <- validate_position(position) do
      %__MODULE__{position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{position: position}) do
      position_indicator(position) <> " \\laissezVibrer"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{position: position}, _opts) do
      concat([
        "#Satie.LaissezVibrer<",
        format_position(position),
        ">"
      ])
    end

    defp format_position(:neutral), do: ""
    defp format_position(position), do: to_string(position)
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = laissez_vibrer) do
      String.Chars.to_string(laissez_vibrer)
    end
  end
end
