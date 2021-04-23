defmodule Copeiro.MixProject do
  use Mix.Project

  def project do
    [
      app: :copeiro,
      version: "0.1.0",
      elixir: "~> 1.9",
      deps: deps(),
      description: "The Copeiro package provides assertion functions that will enhance your testing experience in Elixir",
      package: [
        files: ~w(lib mix.exs README.md LICENSE .formatter.exs),
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/fbeline/copeiro"}
      ],
      name: "Copeiro",
      source_url: "https://github.com/fbeline/copeiro"
    ]
  end

  def application do
    []
  end

  defp deps do
    []
  end
end
