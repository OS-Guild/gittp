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
      %Gittp.Commit{commit |  author: Map.get(params, "author")}
    end 

    json conn, inspect Gittp.Git.write(:git, commit)      
  end

  def create(conn, %{"path" => _, "content" => _, "commit_message" => _} = params) do
    json conn, inspect Gittp.Git.create(:git, params)
  end

end
