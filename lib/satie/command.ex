defmodule Satie.Command do
  @moduledoc false

  defstruct [:command]

  def new(command) do
    %__MODULE__{
      command: command
    }
  end
end

defimpl Satie.ToLilypond, for: Satie.Command do
  def to_lilypond(%Satie.Command{command: command}, _) do
    "\\#{command}"
  end
end
