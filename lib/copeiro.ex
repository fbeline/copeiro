defmodule Copeiro do
  @moduledoc """
  The Copeiro package provides assertion functions that will enhance your testing experience in Elixir
  """

  @doc false
  def __assert_lists__({:==, _, [left, right]}, opts) do
    quote bind_quoted: [left: left, right: right, opts: opts] do
      [left, right] = Copeiro.__map_keys__(left, right, opts)

      in_any_order? = Keyword.get(opts, :any_order, false)

      if in_any_order? do
        left
        |> Copeiro.__match_lists_at_any_order__(right)
        |> case do
          {:error, l, r} ->
            ExUnit.Assertions.flunk("""
            assertion failed, lists does not match
            left: #{inspect(l)}
            right: #{inspect(r)}
            """)

          :ok ->
            true
        end
      else
        assert left == right
      end
    end
  end

  def __assert_lists__({:in, _, [left, right]}, opts) do
    quote bind_quoted: [left: left, right: right, opts: opts] do
      [left, right] = Copeiro.__map_keys__(left, right, opts)

      left
      |> Enum.reduce_while(true, fn l, acc ->
        case l in right do
          true -> {:cont, true}
          false -> {:halt, {:error, l}}
        end
      end)
      |> case do
        {:error, value} ->
          ExUnit.Assertions.flunk("""
          assertion failed, value not found
          value: #{inspect(value)}
          left: #{inspect(left)}
          right: #{inspect(right)}
          """)

        _ ->
          true
      end
    end
  end

  def __assert_lists__({:not, _, [{:in, _, [left, right]}]}, opts) do
    quote bind_quoted: [left: left, right: right, opts: opts] do
      [left, right] = Copeiro.__map_keys__(left, right, opts)

      left
      |> Enum.reduce_while(true, fn l, acc ->
        case l not in right do
          true -> {:cont, true}
          false -> {:halt, {:error, l}}
        end
      end)
      |> case do
        {:error, value} ->
          ExUnit.Assertions.flunk("""
          match succeeded, but should have failed
          value: #{inspect(value)}
          left: #{inspect(left)}
          right: #{inspect(right)}
          """)

        _ ->
          true
      end
    end
  end

  def __assert_lists__({op, _, [left, right]}, _opts) when op in [:=, :==] do
    quote do
      unquote({:assert, [], [{op, [], [left, right]}]})
    end
  end

  @doc false
  def __map_keys__(left, right, opts) do
    keys = Keyword.get(opts, :keys, [])

    if keys == [] do
      [left, right]
    else
      t = fn lst -> Enum.map(lst, &Map.take(&1, keys)) end
      [t.(left), t.(right)]
    end
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

    iex> assert_lists [{:a, 1}, {:c, 3}] in [{:a, 1}, {:b, 2}, {:c, 3}]
    true
    ```

  ### `LEFT` and `RIGHT` has no element in common

    ```
    iex> assert_lists [1, 2] not in [3, 4]
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

  ### Asserting lists of maps/structs

    ```
    iex> assert_lists [%{a: 1}, %{a: 2}] in [%{a: 1, b: 1}, %{a: 2, b: 2}, %{a: 3, b: 3}], keys: [:a]
    true

    iex> assert_lists [%{a: 1}, %{a: 2}] == [%{a: 2, b: 2}, %{a: 1, b: 1}], keys: [:a], any_order: true
    true
    ```
  """
  defmacro assert_lists(expr, opts \\ []) do
    quote do: unquote(__assert_lists__(expr, opts))
  end
end
