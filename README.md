# Copeiro [![Elixir CI](https://github.com/fbeline/copeiro/actions/workflows/elixir.yml/badge.svg?branch=master)](https://github.com/fbeline/copeiro/actions/workflows/elixir.yml)

<img align="left" height="300" src="https://user-images.githubusercontent.com/5730881/116327729-cf9fea00-a79d-11eb-9be4-d4fa5ece38ae.jpg">


>  With Copeiro, you can do twice the work in half the time.
>
> -- <cite>satisfied customer</cite>

### Reasons:

- Only $0
- 90 Day Money Back Guarantee!

### Dedicated support

If you have any questions, please do not hesitate to contact us at telephone number __1-8000-ExUnit__

---

## Goal

The main goal is to extend the ExUnit testing framework with an idiomatic DSL.

```elixir
assert_lists [{:c, 3}, {:a, 1}] in [{:c, 3}, {:b, 2}, {:a, 1}]
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

Using Copeiro in a test file

```elixir
def HelloWorldTest do
  use ExUnit.Case, async: true

  require Copeiro
  import Copeiro

  # ...
end
```

Adding Copeiro to your [CaseTemplate](https://hexdocs.pm/ex_unit/ExUnit.CaseTemplate.html) _(recommended)_

```elixir
defmodule MyCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # This code is injected into every case that calls "use MyCase"
      require Copeiro
      import Copeiro
    end
  end
end
```

## Examples

  For the following examples `LEFT` and `RIGHT` will be used to describe the expression:
  
  `assert_lists LEFT OPERATOR RIGHT`

### All elements of `LEFT` are also elements of `RIGHT`

  ```elixir
  iex> assert_lists [1, 2] in [0, 2, 1, 3]
  true

  iex> assert_lists [{:b, 2}, {:a, 1}] in [{:a, 1}, {:b, 2}, {:c, 3}]
  true
  ```

### `LEFT` and `RIGHT` has no element in common

  ```elixir
  iex> assert_lists [1, 2] not in [3, 4]
  true

  iex> assert_lists [%{c: 3}, %{d: 4}] not in [%{a: 1}, %{b: 2}]
  true
  ```

### Asserts that two lists matches in any order

  ```elixir
  iex> assert_lists [1, 2, 3] == [2, 1, 3], any_order: true
  true

  iex> assert_lists [{:a, 0}, {:b, 1}, {:c, 3}] == [{:a, 0}, {:c, 3}, {:b, 1}], any_order: true
  true
  ```

### Asserting lists of maps/structs

  When asserting maps and or structs you can compose the expression with `keys`

  ```elixir
  iex> assert_lists [%{a: 1}, %{a: 2}] in [%{a: 1, b: 1}, %{a: 2, b: 2}, %{a: 3, b: 3}], keys: [:a]
  true

  iex> assert_lists [%Person{name: "john", age: 20}] == [%Person{name: "Jane", age: 20}], keys: [:age]
  true
  ```

## Helpful error messages

  ```
  assert_lists [%{d: 4}, %{a: 1}] not in [%{a: 1}, %{b: 2}]

     match succeeded, but should have failed
     value: %{a: 1}
     left: [%{d: 4}, %{a: 1}]
     right: [%{a: 1}, %{b: 2}]
  ```

## License

MIT License

Copyright (c) 2021 Felipe Beline Baravieira