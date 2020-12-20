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

  def attach_in(%{music: _} = tree, path, attachment) do
    update_in(tree, path, fn leaf -> Satie.attach(leaf, attachment) end)
  end

  defp normalize_spanner_range(_.._ = range, _), do: range
  defp normalize_spanner_range([h | _] = range, _) when is_integer(h), do: range

  defp normalize_spanner_range([_ | _] = range, tree) do
    with pathed_leaves <- pathed_leaves(tree) do
      Enum.map(range, fn leaf ->
        Enum.find_index(pathed_leaves, fn {_, l} -> l == leaf end)
      end)
    end
  end

  def attach_spanner(%{music: _} = tree, spanner, range) do
    range = normalize_spanner_range(range, tree)

    with pathed_leaves <- pathed_leaves(tree) do
      tree =
        Enum.reduce(range, tree, fn index, t ->
          {path, _} = Enum.at(pathed_leaves, index)

          update_in(t, path, fn elem ->
            attach_spanner(elem, spanner, spanner_position(index, range))
          end)
        end)

      {spanner, tree}
    end
  end

  def attach_spanner(%{spanners: spanners} = leaf, spanner, position) do
    %{leaf | spanners: [{spanner, position} | spanners]}
  end

  def detach_spanner(%{music: _} = tree, spanner) do
    with pathed_leaves <- pathed_leaves(tree) do
      spanned_leaves =
        Enum.filter(pathed_leaves, fn {_, %{spanners: spanners}} ->
          Enum.any?(spanners, fn {span, _} -> span == spanner end)
        end)

      tree =
        Enum.reduce(spanned_leaves, tree, fn {path, _}, t ->
          update_in(t, path, fn leaf ->
            detach_spanner(leaf, spanner)
          end)
        end)

      {spanner, tree}
    end
  end

  def detach_spanner(%{spanners: spanners} = leaf, spanner) do
    new_spanners = Enum.reject(spanners, fn {span, _} -> span == spanner end)
    %{leaf | spanners: new_spanners}
  end

  defp spanner_position(a, a.._), do: :beginning
  defp spanner_position(b, _..b), do: :end
  defp spanner_position(_, _.._), do: :middle
  defp spanner_position(a, [a | _]), do: :beginning

  defp spanner_position(b, [_ | tail]) do
    case Enum.reverse(tail) do
      [^b | _] -> :end
      _ -> :middle
    end
  end

  def parentage(leaf, root) do
    leaves = pathed_leaves(root)
    {path, ^leaf} = Enum.find(leaves, fn {_, l} -> l == leaf end)

    all_paths =
      List.foldl(path, [], fn x, acc ->
        case acc do
          [] -> [[x]]
          [h | _] -> [[x | h] | acc]
        end
      end)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.drop(1)

    Enum.map(all_paths, &get_in(root, &1)) ++ [root]
  end

  def leaves_in(%{music: _} = tree, name) do
    tree
    |> leaves()
    |> Enum.filter(fn leaf ->
      with p <- parentage(leaf, tree) do
        Enum.any?(p, fn ancestor -> Map.get(ancestor, :name) == name end)
      end
    end)
  end

  def leaves(%{music: music}) do
    Enum.map(music, &leaves/1) |> List.flatten()
  end

  def leaves(leaf), do: leaf

  def pathed_leaves(%{music: _} = container) do
    do_pathed_leaves(container, []) |> List.flatten()
  end

  def pathed_leaves(leaf), do: leaf

  defp do_pathed_leaves(%{music: music}, current_path) when is_list(music) do
    music
    |> Enum.with_index()
    |> Enum.map(fn {elem, index} ->
      do_pathed_leaves(elem, [index | current_path])
    end)
  end

  defp do_pathed_leaves(leaf, current_path), do: {Enum.reverse(current_path), leaf}

  defdelegate to_lilypond(music), to: Satie.ToLilypond
  defdelegate to_lilypond(music, opts), to: Satie.ToLilypond
end
