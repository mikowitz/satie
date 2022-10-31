defmodule Satie do
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
end
