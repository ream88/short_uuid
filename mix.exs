defmodule ShortUUID.MixProject do
  use Mix.Project

  @version "3.0.0"
  @url "https://github.com/ream88/short_uuid"
  @maintainers ["Mario Uher"]

  def project do
    [
      app: :short_uuid,
      version: @version,
      elixir: ">= 1.7.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),

      # Docs
      name: "ShortUUID",
      source_url: @url,
      docs: [
        main: "ShortUUID",
        api_reference: false,
        extras: ["README.md", "CHANGELOG.md", "LICENSE"]
      ]
    ]
  end

  def application do
    []
  end

  defp description do
    "Encode UUIDs into Base58, with optional Ecto integration for prefixed IDs (e.g., usr_F6tzXELwufrXBFtFTKsUvc)."
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{"GitHub" => @url, "Changelog" => "#{@url}/blob/main/CHANGELOG.md"}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.0", optional: true},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:stream_data, "~> 0.5 or ~> 1.0", only: :test}
    ]
  end
end
