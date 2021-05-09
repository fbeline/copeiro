defmodule Copeiro.MixProject do
  use Mix.Project

  def project do
    [
      app: :copeiro,
      version: "0.1.1",
      elixir: "~> 1.9",
      deps: deps(),
      name: "Copeiro",
      source_url: "https://github.com/fbeline/copeiro",
      description:
        "The Copeiro package provides assertion functions that will enhance your testing experience in Elixir",
      package: [
        files: ~w(lib mix.exs README.md LICENSE .formatter.exs),
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/fbeline/copeiro"}
      ],
      docs: [
        main: "Copeiro",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:propcheck, "~> 1.3", only: [:test, :dev]},
      {:ex_doc, "~> 0.24 or >= 0.0.0", only: :dev, runtime: false, optional: true},
      {:credo, "~> 1.5 or >= 0.0.0", only: [:dev, :test], runtime: false, optional: true}
    ]
  end
end
