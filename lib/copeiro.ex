defmodule Copeiro do
  @moduledoc """
  """

  defmacro assert_lists({op, _, [left, right]}, :any_order) when op in [:=, :==] do
    quote do
      r = Copeiro.__match_lists_at_any_order__(unquote(left), unquote(right))

      case r do
        :ok ->
          true

        {:error, l, r} ->
          ExUnit.Assertions.flunk("""
          lists does not match
          left: #{inspect(l)}
          right: #{inspect(r)}
          """)
      end
    end
  end

  defmacro assert_lists({op, _, [left, right]}) when op in [:=, :==] do
    quote do
      unquote({:assert, [], [{op, [], [left, right]}]})
    end
  end

  defmacro assert_lists({:in, _meta, [left, right]}) do
    combinations = Copeiro.__match_combinations__(left, right)

    quote do
      unquote(combinations)
      |> Copeiro.__reduce_combinations__()
      |> case do
        [] ->
          true

        missing_patterns ->
          ExUnit.Assertions.flunk("""
          could not match patterns: #{Enum.join(missing_patterns, ", ")}
          right: #{inspect(unquote(right))}
          """)
      end
    end
  end

  defmacro assert_lists({:not, _, [{:in, _, [left, right]}]}) do
    combinations = Copeiro.__match_combinations__(left, right)

    quote do
      unquote(combinations)
      |> Copeiro.__reduce_combinations__(:not_in)
      |> case do
        [] ->
          true

        patterns ->
          ExUnit.Assertions.flunk("""
          matched patterns: #{Enum.join(patterns, ", ")}
          right: #{inspect(unquote(right))}
          """)
      end
    end
  end

  def __reduce_combinations__(combinations, op \\ :in) do
    combinations
    |> Enum.filter(fn r ->
      any? = Enum.any?(r, fn [ok?, _] -> ok? end)
      if op == :not_in, do: any?, else: not any?
    end)
    |> Enum.reduce([], fn [[_, l] | _], acc -> [l | acc] end)
  end

  def __match_combinations__(left, right) do
    Enum.map(left, fn l ->
      Enum.map(right, fn r ->
        [{:match?, [], [l, r]}, Macro.to_string(l)]
      end)
    end)
  end

  def __match_lists_at_any_order__([], []) do
    :ok
  end

  def __match_lists_at_any_order__([], right) do
    {:error, [], right}
  end

  def __match_lists_at_any_order__([left | t], right) do
    right
    |> Enum.find_index(&(&1 == left))
    |> case do
      nil ->
        {:error, left, right}

      idx ->
        __match_lists_at_any_order__(
          t,
          List.delete_at(right, idx)
        )
    end
  end
end
