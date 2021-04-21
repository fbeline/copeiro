defmodule Copeiro do
  @moduledoc """
  """

  # defmacro assert_lists({:=, meta, [left, right]}, key) do
  #   sleft =
  #     left
  #     |> Enum.sort_by(fn {_, _, values} ->
  #       Keyword.get(values, key)
  #     end)

  #   sright =
  #     quote do
  #       unquote(right) |> Enum.sort_by(fn m -> Map.get(m, unquote(key)) end)
  #     end

  #   quote do
  #     unquote({:assert, meta, [{:=, [], [sleft, sright]}]})
  #   end
  # end

  defmacro assert_lists({:in, _meta, [left, right]}) do
    combinations = Copeiro.__match_combinations__(left, right)

    quote do
      unquote(combinations)
      |> Copeiro.__reduce_combinations__()
      |> case do
        [] ->
          assert true

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
          assert true

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
end
