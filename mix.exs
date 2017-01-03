defmodule Metex.Mixfile do
  use Mix.Project

  def project do
    [app: :metex,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.10.0"},
      {:json,      "~> 1.0"}
    ]
  end
end
