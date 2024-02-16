defmodule GitlabCli do
  @moduledoc """
  GitlabCli
  """

  @doc """
  create merge request

  ## Examples

      iex> GitlabCli.create_mr(54958131, "dev", "main", "src/dev.yml", "charge-backend:.*", "charge-backend:foobar")
      :ok
  """
  @spec create_mr(
          project_id :: integer,
          source_branch :: String.t(),
          target_branch :: String.t(),
          file_path :: String.t(),
          pattern :: String.t(),
          content :: String.t()
        ) :: String.t()
  def create_mr(project_id, source_branch, target_branch, file_path, pattern, content) do
    # create branch
    GitlabCli.Gitlab.create_branch(project_id, source_branch, target_branch)

    # get latest file content from target branch
    file_raw = GitlabCli.Gitlab.get_file_raw(project_id, file_path, target_branch)
    # update file
    new_file = String.replace(file_raw, ~r/#{pattern}/, content)

    # create commit
    GitlabCli.Gitlab.create_commit(project_id, source_branch, "update #{file_path}", [
      %{
        action: "update",
        file_path: file_path,
        content: new_file
      }
    ])

    # create merge request
    GitlabCli.Gitlab.create_mr(project_id, source_branch, target_branch, "update #{file_path}")
  end
end
