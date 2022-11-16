defmodule Satie.Dynamic do
  defstruct [:name, :position]

  use Satie.Attachable
  import Satie.Validations

  @doc """

      iex> Dynamic.new("ff")
      #Satie.Dynamic<- \\ff>

      iex> Dynamic.new("ppp", :down)
      #Satie.Dynamic<_ \\ppp>

  """
  def new(name, position \\ :neutral) do
    with position <- validate_position(position) do
      %__MODULE__{name: name, position: position}
    end
  end

  defimpl String.Chars do
    import Satie.StringHelpers

    def to_string(%@for{name: name, position: position}) do
      position_indicator(position) <> " \\#{name}"
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{} = dynamic, _opts) do
      concat([
        "#Satie.Dynamic<",
        to_string(dynamic),
        ">"
      ])
    end
  end

  defimpl Satie.ToLilypond do
    def to_lilypond(%@for{} = dynamic) do
      to_string(dynamic)
    end
  end
end
