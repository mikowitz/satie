defmodule Satie do
  def append(%{music: music} = container, element_or_elements) do
    %{ container | music: music ++ List.wrap(element_or_elements) }
  end

  def insert(%{music: music} = container, element_or_elements, index \\ 0) do
    %{ container |
      music: List.flatten(List.insert_at(music, index, element_or_elements))
    }
  end
end
