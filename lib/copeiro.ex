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
    combinations = for l <- left, r <- right, do: Copeiro.__match__(l, r)

    quote do
      combinations = unquote(combinations)

      combinations
      |> Enum.group_by(fn [l, _, _] -> l end)
      |> Map.values()
      |> Enum.filter(fn results ->
        results
        |> Enum.any?(fn [_, _, ok?] -> ok? end)
        |> Kernel.not()
      end)
      |> Enum.reduce([], fn [[l, _, _] | _], acc -> [l | acc] end)
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

  def __match__(left, right) do
    [
      Macro.to_string(left),
      Macro.to_string(right),
      {:match?, [], [left, right]}
    ]
  end
end
