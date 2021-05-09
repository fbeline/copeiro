defmodule Copeiro.Comparator do
  @moduledoc false

  @doc false
  def match_lists_in_any_order([], []) do
    :ok
  end

  def match_lists_in_any_order([], right) do
    {:error, {:right, right}}
  end

  def match_lists_in_any_order([left | t], right) do
    right
    |> Enum.find_index(&(&1 == left))
    |> case do
      nil ->
        {:error, {:left, [left]}}

      idx ->
        match_lists_in_any_order(
          t,
          List.delete_at(right, idx)
        )
    end
  end
end
