# Copeiro [![Elixir CI](https://github.com/fbeline/copeiro/actions/workflows/elixir.yml/badge.svg?branch=master)](https://github.com/fbeline/copeiro/actions/workflows/elixir.yml)

![L'Echanson_-_Allégorie_de_la_Tempérance](https://user-images.githubusercontent.com/5730881/115628971-d929dd80-a2d7-11eb-89d7-dade63df0c6d.JPG)

## Motivation

To enchance the ExUnit testing framework, as it does not provide functions for lists assertion.

The Copeiro main idea is to fill this gap with a powerfull idiomatic DSL. Example:

```elixir
a = 1
assert_lists [{:c, _}, {:a, ^a}] in [{:c, 3}, {:b, 2}, {:a, 1}]
```

## Installation

```elixir
def deps do
  [
    {:copeiro, "~> 0.1.0", only: :test}
  ]
end
```

## Usage

```elixir
def HelloWorldTest do
  use ExUnit.Case, async: true

  require Copeiro
  import Copeiro

  # ...
end
```

## Examples

For the following examples we will use `LEFT` and `RIGHT` to describe the expression:

`assert_lists LEFT OPERATOR RIGHT`

### All elements of `LEFT` are also elements of `B`

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