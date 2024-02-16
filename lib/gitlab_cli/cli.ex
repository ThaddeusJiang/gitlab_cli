defmodule GitlabCli.CLI do
  @moduledoc """
  escript main_module
  """

  @doc """
  Main entry point for the Gitlab CLI

  ## Examples

      iex> GitlabCli.CLI.main(["--help"])
      Usage: gitlab_cli [options]
      Options:
        --help  Show this help message and exit
      :ok

      iex> GitlabCli.CLI.main(["--project-id", "54958131", "--source-branch", "dev", "--target-branch", "main", "--file-path", "dev.yml", "--pattern", "charge-backend:.*", "--content", "charge-backend:foobar"])
      :ok

  """
  def main(args \\ []) do
    args
    |> parse_args()
    |> response()
  end

  def parse_args(args) do
    {opts, _args, _} =
      OptionParser.parse(args,
        switches: [
          help: :boolean,
          project_id: :string,
          source_branch: :string,
          target_branch: :string,
          file_path: :string,
          pattern: :string,
          content: :string
        ],
        aliases: [
          h: :help,
          p: :project_id,
          s: :source_branch,
          t: :target_branch,
          f: :file_path,
          pt: :pattern,
          c: :content
        ]
      )

    case opts do
      [] -> :help
      _ -> {:create_mr, opts}
    end
  end

  @doc """
  print help message

  ## Examples

      iex> GitlabCli.CLI.response(:help)
      Usage: gitlab_cli [options]
      Options:
        --help  Show this help message and exit
      :ok
  """
  def response(:help) do
    IO.puts("Usage: gitlab_cli [options]")
    IO.puts("Options:")
    IO.puts("  --help  Show this help message and exit")
    System.halt(0)
  end

  def response({:create_mr, opts}) do
    GitlabCli.create_mr(
      opts[:project_id],
      opts[:source_branch],
      opts[:target_branch],
      opts[:file_path],
      opts[:pattern],
      opts[:content]
    )
  end
end
