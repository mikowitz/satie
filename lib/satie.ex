defmodule Satie do
  def to_lilypond(x), do: Satie.ToLilypond.to_lilypond(x)

  def lilypondable?(%{__struct__: struct}) do
    {:consolidated, impls} = Satie.ToLilypond.__protocol__(:impls)
    struct in impls
  end

  def lilypondable?(_), do: false
end
