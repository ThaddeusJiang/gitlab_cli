defmodule GitlabCli.Gitlab do
  @moduledoc """
  GitLab API
  """
  alias Req

  defp get_gitlab_config do
    %{
      gitlab_api_url: System.get_env("CI_API_V4_URL") || "https://gitlab.com/api/v4",
      gitlab_private_token: System.get_env("GITLAB_PRIVATE_TOKEN")
    }
  end

  def init() do
    %{
      gitlab_api_url: gitlab_api_url,
      gitlab_private_token: private_token
    } = get_gitlab_config()

    headers = [
      {"PRIVATE-TOKEN", private_token},
      {"Content-Type", "application/json"}
    ]

    Req.new(
      base_url: gitlab_api_url,
      headers: headers,
      connect_options: [
        transport_opts: [
          cacertfile: "priv/cacerts.pem"
        ]
      ]
    )
  end

  @spec get_file_raw(
          project_id :: integer,
          file_path :: String.t(),
          ref :: String.t()
        ) :: String.t() | nil
  def get_file_raw(project_id, file_path, ref \\ "") do
    req = init()

    encoded_file_path = URI.encode_www_form(file_path)

    # GET /projects/:id/repository/files/:file_path/raw
    url = "/projects/#{project_id}/repository/files/#{encoded_file_path}/raw"

    params = [
      ref: ref || get_default_branch(project_id)
    ]

    case Req.get(req, url: url, params: params) do
      # 200
      {:ok, %Req.Response{status: 200, body: body}} ->
        body

      # 404
      {:ok, %Req.Response{status: 404}} ->
        IO.puts("Warning: can not get file, since 404")
        nil

      {:error, reason} ->
        IO.puts("Error: can not get file, since #{reason}")
        nil
    end
  end

  def list_branches(id) do
    req = init()
    url = "/projects/#{id}/repository/branches"

    case Req.get(req, url: url) do
      {:ok, resp} ->
        resp.body

      {:error, reason} ->
        IO.puts("Error: can not list branches, since #{reason}")
        []
    end
  end

  def get_default_branch(id) do
    list_branches(id)
    |> Enum.find_value(fn branch ->
      case branch["default"] do
        true -> branch["name"]
        false -> nil
      end
    end)
  end

  def create_branch(id, branch, ref \\ "") do
    req = init()

    # curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/repository/branches?branch=newbranch&ref=main"
    url = "/projects/#{id}/repository/branches"

    ref = ref || get_default_branch(id)

    params = [
      branch: branch,
      ref: ref
    ]

    case Req.post(req, url: url, params: params) do
      {:ok, %Req.Response{status: 409}} ->
        IO.puts("Branch already exists: #{branch}")

      {:ok, %Req.Response{status: 201}} ->
        IO.puts("Branch created: #{branch}")

      # FIXME: 400 ,   body: %{"message" => "Branch already exists"},
      {:ok, %Req.Response{status: 400, body: %{"message" => reason}}} ->
        IO.puts("Warning: can not create branch, since #{reason}")

      {:ok, resp} ->
        IO.inspect(resp)

      {:error, reason} ->
        IO.puts("Error: can not create branch, since #{reason}")
    end
  end

  def create_commit(id, branch, commit_message, actions) do
    req = init()
    url = "/projects/#{id}/repository/commits"

    body =
      %{
        branch: branch,
        commit_message: commit_message,
        actions: actions
      }
      |> Jason.encode!()

    # post /projects/:id/repository/commits

    case Req.post(req, url: url, body: body) do
      {:ok, resp} ->
        resp.body

      {:error, reason} ->
        IO.puts("Error: can not create commit, since #{reason}")
    end
  end

  def create_mr(id, source_branch, target_branch, title) do
    req = init()
    # POST /projects/:id/merge_requests
    url = "/projects/#{id}/merge_requests"

    body =
      %{
        source_branch: source_branch,
        target_branch: target_branch,
        title: title
      }
      |> Jason.encode!()

    case Req.post(req, url: url, body: body) do
      {:ok, %Req.Response{status: 409, body: %{"message" => reason}}} ->
        IO.puts("Warning: can not create merge request, since #{reason}")

      {:ok, %Req.Response{status: 201}} ->
        IO.puts("Merge request created")

      {:ok, resp} ->
        IO.inspect(resp)

      {:error, reason} ->
        IO.puts("Error: can not create merge request, since #{reason}")
    end
  end
end
