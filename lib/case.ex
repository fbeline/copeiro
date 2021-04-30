defmodule Copeiro.Case do
  @moduledoc """
  A wrapper over `ExUnit.Case` with Copeiro assertions
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Copeiro
    end
  end
end
