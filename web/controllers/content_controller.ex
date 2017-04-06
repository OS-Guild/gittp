defmodule Gittp.ContentController do
  use Gittp.Web, :controller

  def read(conn, %{"path" => path}) do
    {_, content} = Gittp.Git.content(:git, path)
    json conn, content
  end

  def write(conn, %{"path" => _, "content" => _, "checksum" => _, "commit_message" => _} = params) do
    json conn, inspect Gittp.Git.write(:git, params)      
  end
end
