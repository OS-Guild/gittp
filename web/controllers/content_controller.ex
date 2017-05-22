defmodule Gittp.ContentController do
  use Gittp.Web, :controller
  require Logger

  def read(conn, %{"path" => path}) do
    correct_path = Path.join(path)
    repo_path = Application.get_env(:gittp, Gittp.Endpoint)[:local_repo_path]
    repo = Git.new repo_path
    case Gittp.Repo.content(repo, correct_path) do
      {:ok, content} -> json conn, content
      {:error, error} -> handle_error(conn, error)
    end
  end

  def write(conn, %{"path" => path, "content" => _, "checksum" => _, "commit_message" => _} = params) do
    commit = params
      |> Map.put("path", Path.join(path)) 
      |> Gittp.Commit.from

    case Gittp.Git.write(:git, commit) do
        {:ok, _} -> send_resp(conn, 200, "ok")
        {:error, error} -> handle_error(conn, error)      
    end
  end

  def create(conn, %{"path" => path, "content" => _, "commit_message" => _} = params) do
    commit = = params
      |> Map.put("path", Path.join(path)) 
      |> Gittp.Commit.from

    case Gittp.Git.create(:git, commit) do
      {:ok, _} -> send_resp(conn, 200, "ok")
      {:error, error} -> handle_error(conn, error)
    end
  end

  defp handle_error(conn, error) do 
    case error do
      :checksum_mismatch -> send_resp(conn, 400, "Checksum mismatch, please read the file again")
      :file_exists -> send_resp(conn, 400, "File alredy exists")   
      :enoent -> send_resp(conn, 400, "File does not exist")   
      error -> 
        Logger.error inspect error
        send_resp(conn, 500, "Unknown error")
    end
  end 
end
