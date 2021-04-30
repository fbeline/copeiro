defmodule CopeiroTest do
  use Copeiro.Case
  use PropCheck

  doctest Copeiro

  describe "assert_lists - operator: == -" do
    test "pure assertion" do
      assert_lists [1, 2, 3] == [1, 2, 3]
    end

    test "pure assertion - fail" do
      assert_lists [1, 2, 3] == [3, 2, 1]
    rescue
      error in [ExUnit.AssertionError] ->
        assert """
               Comparison (using ==) failed in:
               left: [1, 2, 3]
               right: [3, 2, 1]
               """ == error.message
    end

    test "in any order" do
      assert_lists [0, 2, 1] == [0, 1, 2], any_order: true

      assert_lists [%{a: 1}, %{b: 2}, %{c: 3}] == [%{a: 1}, %{c: 3}, %{b: 2}], any_order: true
    end

    test "in any order - more elements at left" do
      assert_lists [0, 2, 1, 3] == [0, 1, 2], any_order: true
    rescue
      error in [ExUnit.AssertionError] ->
        assert """
               assertion failed, lists does not match
               left: [0, 2, 1, 3]
               right: [0, 1, 2]
               """ == error.message
    end

    test "in any order - more elements at right" do
      assert_lists [0, 2, 1] == [0, 1, 2, 3], any_order: true
    rescue
      error in [ExUnit.AssertionError] ->
        assert """
               assertion failed, lists does not match
               left: [0, 2, 1]
               right: [0, 1, 2, 3]
               """ == error.message
    end
  end

  describe "assert_lists - operator: in -" do
    test "all elements of LEFT are also elements of RIGHT" do
      assert_lists [1, 2] in [4, 3, 2, 1]
    end

    test "one or more elements of LEFT missing at RIGHT" do
      assert_lists [%{a: 1, b: 1}, %{a: 3, b: 3}] in [%{a: 1, b: 1}, %{a: 2, b: 2}]
    rescue
      error in [ExUnit.AssertionError] ->
        assert """
               assertion failed, value not found
               value: %{a: 3, b: 3}
               left: [%{a: 1, b: 1}, %{a: 3, b: 3}]
               right: [%{a: 1, b: 1}, %{a: 2, b: 2}]
               """ == error.message
    end
  end

  describe "assert_lists - opts: keys -" do
    defmodule Person do
      defstruct name: "John", age: 27
    end

    test "operator: in" do
      assert_lists [%{a: 1}, %{a: 2}] in [%{a: 1, b: 1}, %{a: 2, b: 2}, %{a: 3, b: 3}], keys: [:a]
    end

    test "operator: ==" do
      assert_lists [%{a: 1}, %{a: 2}] == [%{a: 2, b: 2}, %{a: 1, b: 1}],
        keys: [:a],
        any_order: true
    end

    test "work with structs" do
      assert_lists [%Person{name: "john", age: 20}] == [%Person{name: "Jane", age: 20}],
        keys: [:age]
    end
  end

  describe "assert_lists - operator: not in -" do
    test "LEFT and RIGHT has no element in common" do
      assert_lists [%{a: 10}] not in [%{a: 1, b: 1}, %{a: 2, b: 2}]
    end

    test "match succeeded, but should have failed" do
      assert_lists [%{a: 3, b: 1}] not in [%{a: 1, b: 1}, %{a: 2, b: 2}]
    rescue
      error in [ExUnit.AssertionError] ->
        assert "match succeeded, but should have failed" <> _ = error.message
    end
  end

  property "assert_lists - pure " do
    forall input <- list(any()) do
      assert_lists input == input
    end
  end

  property "assert_lists - in any order" do
    forall right <- list(any()) do
      left = Enum.shuffle(right)
      assert_lists left == right, any_order: true
    end
  end

  property "assert_lists - operator: in" do
    forall right <- list(any()) do
      n = Enum.random(1..length(right))
      left = Enum.take_random(right, n)

      assert_lists left in right
    end
  end

  property "assert_lists - operator: not in" do
    forall [aux, right] <- [list(), list()] do
      left = MapSet.difference(MapSet.new(aux), MapSet.new(right))

      assert_lists left not in right
    end
  end
end
