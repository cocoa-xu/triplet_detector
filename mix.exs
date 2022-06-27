defmodule TripletDetector.MixProject do
  use Mix.Project

  @app :triplet_detector
  @version "0.1.0"
  @github_url "https://github.com/cocoa-xu/triplet_detector"
  @precompiled_artefacts_version "0.1.1"

  def project do
    [
      app: @app,
      version: version(),
      elixir: "~> 1.12",
      compilers: Mix.compilers() ++ [:elixir_precompiled_deployer],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "TripletDetector",
      description: "Detecting current node's triplet `ARCH-OS-ABI` in pure Elixir.",
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ssl, :inets]
    ]
  end

  def version, do: @version
  def github_url, do: @github_url
  def precompiled_artefacts_version, do: @precompiled_artefacts_version

  defp deps do
    [
      {:elixir_precompiled_deployer, "~> 0.1", runtime: false},
      {:ex_doc, "~> 0.28", only: [:dev, :docs], runtime: false}
    ]
  end

  defp docs do
    [
      main: "TripletDetector",
      source_ref: "v#{version()}",
      source_url: github_url()
    ]
  end

  defp package() do
    [
      name: to_string(@app),
      files: ~w(priv lib mix.exs README* LICENSE* precompiled_deploy.exs),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => github_url()}
    ]
  end
end
