defmodule Satie do
  @lilypond_version Application.compile_env!(:satie, :lilypond_version)
  @lilypond_executable Application.compile_env!(:satie, :lilypond_executable)

  def lilypond_version, do: @lilypond_version
  def lilypond_executable, do: @lilypond_executable

  def to_lilypond(x), do: Satie.ToLilypond.to_lilypond(x)

  def lilypondable?(%{__struct__: struct}) do
    {:consolidated, impls} = Satie.ToLilypond.__protocol__(:impls)
    struct in impls
  end

  def lilypondable?(_), do: false

  def transpose(%{__struct__: struct} = transposable, %Satie.Interval{} = interval) do
    struct.transpose(transposable, interval)
  end

  def invert(%{__struct__: struct} = transposable, %Satie.Pitch{} = axis) do
    struct.invert(transposable, axis)
  end

  def show(content) do
    case lilypondable?(content) do
      true ->
        content
        |> Satie.Lilypond.LilypondFile.from()
        |> Satie.Lilypond.LilypondFile.show()

      false ->
        {:error, "#{inspect(content)} cannot be formatted in Lilypond"}
    end
  end
end
