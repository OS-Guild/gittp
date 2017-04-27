defmodule Gittp.ContentController do
  use Gittp.Web, :controller

  def read(conn, %{"path" => path}) do
    {_, content} = Gittp.Git.content(:git, path)
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
