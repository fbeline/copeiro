defmodule Copeiro do
  @moduledoc """
  The Copeiro package provides assertion functions that will enhance your testing experience in Elixir
  """

  @doc false
  def __assert_lists__({:==, _, [left, right]}, any_order: true) do
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

  def __assert_lists__({:in, _, [left, right]}, _opts) do
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

  def __assert_lists__({:not, _, [{:in, _, [left, right]}]}, _opts) do
    combinations = Copeiro.__match_combinations__(left, right)

    quote do
      unquote(combinations)
      |> Copeiro.__reduce_combinations__(:not_in)
      |> case do
        [] ->
          true

        patterns ->
          ExUnit.Assertions.flunk("""
          match succeeded, but should have failed
          left: #{Enum.join(patterns, ", ")}
          right: #{inspect(unquote(right))}
          """)
      end
    end
  end

  def __assert_lists__({op, _, [left, right]}, _opts) when op in [:=, :==] do
    quote do
      unquote({:assert, [], [{op, [], [left, right]}]})
    end
  end

  @doc false
  def __reduce_combinations__(combinations, op \\ :in) do
    combinations
    |> Enum.filter(fn r ->
      any? = Enum.any?(r, fn [ok?, _] -> ok? end)
      if op == :not_in, do: any?, else: not any?
    end)
    |> Enum.reduce([], fn [[_, l] | _], acc -> [l | acc] end)
  end

  @doc false
  def __match_combinations__(left, right) do
    Enum.map(left, fn l ->
      Enum.map(right, fn r ->
        [
          {:case, [],
           [
             r,
             [
               do: [
                 {:->, [generated: true], [[l], true]},
                 {:->, [generated: true], [[{:_, [], Elixir}], false]}
               ]
             ]
           ]},
          Macro.to_string(l)
        ]
      end)
    end)
  end

  @doc false
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

  @doc """
  Asserts that two lists matches

  ## Examples

  For the following examples`LEFT` and `RIGHT` will be used to describe the expression `assert_lists LEFT OPERATOR RIGHT`

  ### All elements of `LEFT` are also elements of `RIGHT`

    ```
    iex> assert_lists [1, 2] in [0, 2, 1, 3]
    true

    iex> assert_lists [{:b, _}, {:a, 1}] in [{:a, 1}, {:b, 2}, {:c, 3}]
    true

    iex> assert_lists [%{b: 2}] in [%{a: 1}, %{b: 2, c: 10}]
    true
    ```

  ### `LEFT` and `RIGHT` has no element in common

    ```
    iex> assert_lists [1, 2] not in [3, 4]
    true

    iex> assert_lists [{:c, _}] not in [{:a, 1}, {:b, 2}]
    true

    iex> assert_lists [%{c: 3}, %{d: 4}] not in [%{a: 1}, %{b: 2}]
    true
    ```

  ### Asserts that two lists matches in any order

    ```
    iex> assert_lists [1, 2, 3] == [2, 1, 3], any_order: true
    true

    iex> assert_lists [{:a, 0}, {:b, 1}, {:c, 3}] == [{:a, 0}, {:c, 3}, {:b, 1}], any_order: true
    true
    ```
  """
  defmacro assert_lists(expr, opts \\ []) do
    quote do: unquote(__assert_lists__(expr, opts))
  end
end
