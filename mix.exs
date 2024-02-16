defmodule GitlabCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :gitlab_cli,
      version: "0.1.0",
      elixir: "~> 1.15",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      description: description(),
      package: package(),
      deps: deps(),
      name: "GitLab CLI",
      source: "https://github.com/ThaddeusJiang/gitlab_cli",
      authors: ["ThaddeusJiang"],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:req, "~> 0.4.0"}, FIXME: 0.4.9
      {:req, "0.4.9"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp escript do
    [
      main_module: GitlabCli.CLI
    ]
  end

  defp description do
    """
    GitLab’s unofficial command line tool
    """
  end

  defp package do
    [
      name: "gitlab_cli",
      files: ~w(lib priv mix.exs README*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ThaddeusJiang/gitlab_cli"},
      maintainers: ["ThaddeusJiang"]
    ]
  end
end
