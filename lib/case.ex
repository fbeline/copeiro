defmodule Copeiro.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      require Copeiro
      import Copeiro
    end
  end
end
