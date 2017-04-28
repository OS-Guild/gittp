defmodule Gittp.ContentController do
  use Gittp.Web, :controller
  require Logger

  def read(conn, %{"path" => path}) do
    repo_path = Application.get_env(:gittp, Gittp.Endpoint)[:local_repo_path]
    repo = Git.new repo_path
    {_, content} = Gittp.Repo.content(repo, path)
    json conn, content
  end

  def write(conn, %{"path" => path, 
                    "content" => content, 
                    "checksum" => checksum, 
                    "commit_message" => commit_message} = params) do
    commit = %Gittp.Commit{path: path, content: content, checksum: checksum, commit_message: commit_message}                  
    commit = if Map.has_key?(params, "author") do
      %Gittp.Commit{commit | author: Map.get(params, "author")}
    end 

    case Gittp.Git.write(:git, commit) do
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

  def create(conn, %{"path" => path, "content" => content, "commit_message" => commit_message} = params) do
    commit = %Gittp.Commit{path: path, content: content, commit_message: commit_message}                  
    commit = if Map.has_key?(params, "author") do
      %Gittp.Commit{commit | author: Map.get(params, "author")}
    end 

    case Gittp.Git.create(:git, commit) do
      {:ok, _} -> send_resp(conn, 200, "ok")
      {:error, error} -> handle_error(conn, error)
    end
  end
end
