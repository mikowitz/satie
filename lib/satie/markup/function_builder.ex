defmodule Satie.Markup.FunctionBuilder do
  @moduledoc """
    Macros to construct Markup functions
  """

  alias __MODULE__

  defmacro build_entity(command) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)() do
        %{
          command: to_string(unquote(command))
        }
      end
    end
  end

  defmacro build_entity(command, argnames) when is_list(argnames) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(unquote_splicing(argnames)) do
        %{
          command: to_string(unquote(command)),
          arguments: [unquote_splicing(argnames)]
        }
      end
    end
  end

  defmacro build_entity(command, argname) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(unquote(argname)) do
        %{
          command: to_string(unquote(command)),
          argument: unquote(argname)
        }
      end
    end
  end

  defmacro build_entity_with_overrides(command, override_keys) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(overrides \\ []) do
        with {:ok, overrides} <-
               FunctionBuilder.validate_overrides(
                 overrides,
                 unquote(override_keys),
                 unquote(function_name)
               ) do
          %{
            command: to_string(unquote(command)),
            overrides: overrides
          }
        end
      end
    end
  end

  defmacro build_entity_with_overrides(command, argnames, override_keys) when is_list(argnames) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(unquote_splicing(argnames), overrides \\ []) do
        with {:ok, overrides} <-
               FunctionBuilder.validate_overrides(
                 overrides,
                 unquote(override_keys),
                 unquote(function_name)
               ) do
          %{
            command: to_string(unquote(command)),
            arguments: [unquote_splicing(argnames)],
            overrides: overrides
          }
        end
      end
    end
  end

  defmacro build_entity_with_overrides(command, argname, override_keys) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(unquote(argname), overrides \\ []) do
        with {:ok, overrides} <-
               FunctionBuilder.validate_overrides(
                 overrides,
                 unquote(override_keys),
                 unquote(function_name)
               ) do
          %{
            command: to_string(unquote(command)),
            argument: unquote(argname),
            overrides: overrides
          }
        end
      end
    end
  end

  defmacro build_function(command) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(content) do
        %{
          command: to_string(unquote(command)),
          content: content
        }
      end
    end
  end

  defmacro build_function(command, argnames) when is_list(argnames) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(content, unquote_splicing(argnames)) do
        %{
          command: to_string(unquote(command)),
          arguments: [unquote_splicing(argnames)],
          content: content
        }
      end
    end
  end

  defmacro build_function(command, argname) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(content, unquote(argname)) do
        %{
          command: to_string(unquote(command)),
          argument: unquote(argname),
          content: content
        }
      end
    end
  end

  defmacro build_function_with_overrides(command, override_keys) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(content, overrides \\ []) do
        with {:ok, overrides} <-
               FunctionBuilder.validate_overrides(
                 overrides,
                 unquote(override_keys),
                 unquote(function_name)
               ) do
          %{
            command: to_string(unquote(command)),
            overrides: overrides,
            content: content
          }
        end
      end
    end
  end

  defmacro build_function_with_overrides(command, argname, override_keys) do
    function_name = command_to_function_name(command)

    quote do
      def unquote(function_name)(content, unquote(argname), overrides \\ []) do
        with {:ok, overrides} <-
               FunctionBuilder.validate_overrides(
                 overrides,
                 unquote(override_keys),
                 unquote(function_name)
               ) do
          %{
            command: to_string(unquote(command)),
            overrides: FunctionBuilder.process_overrides(overrides),
            argument: unquote(argname),
            content: content
          }
        end
      end
    end
  end

  def validate_overrides([], _valid_keys, _function_name), do: {:ok, []}

  def validate_overrides(overrides, valid_keys, function_name) do
    overrides = process_overrides(overrides)

    case Enum.filter(Map.keys(overrides), &(&1 not in valid_keys)) do
      [] -> {:ok, overrides}
      invalid_keys -> {:error, "invalid override keys given to #{function_name}", invalid_keys}
    end
  end

  defp command_to_function_name(command) when is_atom(command), do: command

  defp command_to_function_name(command) when is_bitstring(command) do
    command
    |> Macro.underscore()
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  def process_overrides([]), do: []

  def process_overrides(list) when is_list(list) do
    Enum.map(list, fn {k, v} -> {underscores_to_dashes(k), v} end)
    |> Enum.into(%{})
  end

  defp underscores_to_dashes(atom) do
    atom |> to_string() |> String.replace("_", "-")
  end
end
