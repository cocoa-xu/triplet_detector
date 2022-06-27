defmodule TripletDetector.MixProject do
  use Mix.Project

  @app :triplet_detector
  @version "0.1.0"
  @github_url "https://github.com/cocoa-xu/triplet_detector"

  def project do
    [
      app: @app,
      version: version(),
      elixir: "~> 1.12",
      compilers: [:elixir_precompiled_deployer] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "TripletDetector",
      description: "Detecting current machine's triplet `ARCH-OS-ABI` in pure Elixir.",
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def version, do: @version
  def github_url, do: @github_url

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
      files: ~w(priv lib mix.exs  README* LICENSE* precompiled_deploy.exs),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => github_url()}
    ]
  end
end
