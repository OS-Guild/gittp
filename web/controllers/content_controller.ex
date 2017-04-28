defmodule Gittp.ContentController do
  use Gittp.Web, :controller
  require Logger

  def read(conn, %{"path" => path}) do
    repo_path = Application.get_env(:gittp, Gittp.Endpoint)[:local_repo_path]
    repo = Git.new repo_path
    {_, content} = Gittp.Repo.content(repo, path)
    json conn, content
  end

  def write(conn, %{"path" => _, "content" => _, "checksum" => _, "commit_message" => _} = params) do
    commit = Gittp.Commit.from params

    case Gittp.Git.write(:git, commit) do
        {:ok, _} -> send_resp(conn, 200, "ok")
        {:error, error} -> handle_error(conn, error)      
    end
  end

  def create(conn, %{"path" => _, "content" => _, "commit_message" => _} = params) do
    commit = Gittp.Commit.from params

    case Gittp.Git.create(:git, commit) do
      {:ok, _} -> send_resp(conn, 200, "ok")
      {:error, error} -> handle_error(conn, error)
    end
  end

  defp handle_error(conn, error) do 
    case error do
      :checksum_mismatch -> send_resp(conn, 400, "Checksum mismatch, please read the file again")
      :file_exists -> send_resp(conn, 400, "File alredy exists")      
      error -> send_resp(conn, 500, inspect error)
    end
  end 
end
