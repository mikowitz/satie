defmodule Satie do
  @moduledoc false

  def append(%{music: music} = container, element_or_elements) do
    %{container | music: music ++ List.wrap(element_or_elements)}
  end

  def insert(%{music: music} = container, element_or_elements, index \\ 0) do
    %{container | music: List.flatten(List.insert_at(music, index, element_or_elements))}
  end

  def show(music) do
    Satie.Lilypond.show(music)
  end

  def save(music, filename \\ nil) do
    Satie.Lilypond.save(music, filename)
  end

  def attach(%{attachments: atts} = music, attachment) do
    %{music | attachments: [attachment | atts]}
  end

  defdelegate to_lilypond(music), to: Satie.ToLilypond
end
