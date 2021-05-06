defmodule Copeiro do
  @moduledoc """
  The Copeiro package provides assertion functions that will enhance your testing experience in Elixir
  """

  @doc false
  def __assert_lists__(:==, left, right, any_order: true) do
    left
    |> Copeiro.Comparator.match_lists_in_any_order(right)
    |> case do
      {:error, _, _} ->
        ExUnit.Assertions.flunk("""
        assertion failed, lists does not match
        left: #{inspect(left)}
        right: #{inspect(right)}
        """)

      :ok ->
        true
    end
  end

  def __assert_lists__(:==, left, right, _opts) do
    if left == right do
      true
    else
      ExUnit.Assertions.flunk("""
      Comparison (using ==) failed in:
      left: #{inspect(left)}
      right: #{inspect(right)}
      """)
    end
  end

  def __assert_lists__(:in, left, right, _opts) do
    left
    |> Enum.reduce_while(true, fn l, _ ->
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

  def __assert_lists__(:not_in, left, right, _opts) do
    left
    |> Enum.reduce_while(true, fn l, _ ->
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

  ### Asserts that two lists match in any order

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
    {op, left, right} =
      case expr do
        {:not, _, [{:in, _, [left, right]}]} -> {:not_in, left, right}
        {op, _, [left, right]} -> {op, left, right}
      end

    quote bind_quoted: [op: op, left: left, right: right, opts: opts] do
      [left, right, opts] =
        (fn left, right, opts ->
           keys = Keyword.get(opts, :keys, [])

           if keys == [] do
             [left, right, opts]
           else
             t = fn lst -> Enum.map(lst, &Map.take(&1, keys)) end
             [t.(left), t.(right), Keyword.delete(opts, :keys)]
           end
         end).(left, right, opts)

      Copeiro.__assert_lists__(op, left, right, opts)
    end
  end
end
