defmodule Satie do
  @moduledoc """
    Satie is a score-modeling library written in Elixir.
  """
  @lilypond_version Application.compile_env!(:satie, :lilypond_version)
  @lilypond_executable Application.compile_env!(:satie, :lilypond_executable)

  alias Satie.Lilypond.LilypondFile

  def lilypond_version, do: @lilypond_version
  def lilypond_executable, do: @lilypond_executable

  def to_lilypond(x, opts \\ []), do: Satie.ToLilypond.to_lilypond(x, opts)

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

  def show(content, lilypond_options \\ []) do
    case lilypondable?(content) do
      true ->
        content
        |> LilypondFile.from(lilypond_options)
        |> LilypondFile.show()

      false ->
        {:error, "#{inspect(content)} cannot be formatted in Lilypond"}
    end
  end

  def append(%{contents: _}, [_ | _] = list) do
    {:error, :cannot_append_by_list, list}
  end

  def append(%{contents: contents} = container, elem) do
    %{container | contents: List.insert_at(contents, -1, elem)}
  end

  def append(x, _), do: {:error, :cannot_append_to_non_container, x}

  def extend(%{contents: contents} = container, [_ | _] = list) do
    %{container | contents: contents ++ list}
  end

  def extend(%{contents: _}, x) do
    {:error, :cannot_extend_by_single_element, x}
  end

  def extend(x, _), do: {:error, :cannot_extend_a_non_container, x}

  def empty(%{contents: _} = tree) do
    %{tree | contents: []}
  end

  def empty(x), do: {:error, :cannot_empty_non_tree, x}

  def attach(target, attachment, options \\ [])

  def attach(%{attachments: attachments} = target, attachment, options) do
    case Satie.IsAttachable.attachable?(attachment) do
      true ->
        new_attachment = Satie.Attachment.new(attachment, options)

        case new_attachment in attachments do
          false ->
            %{target | attachments: [new_attachment | attachments]}

          true ->
            {:error, :duplicate_attachment, attachment}
        end

      false ->
        {:error, :not_attachable, attachment}
    end
  end

  def attach(x, _, _), do: {:error, :cannot_attach_to, x}
end
