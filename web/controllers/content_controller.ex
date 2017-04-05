defmodule Gittp.ContentController do
  use Gittp.Web, :controller

  def read(conn, %{"path" => path}) do
    json conn, Gittp.Git.content(:git, path)
  end

  def write(conn, %{"path" => _, "content" => _, "checksum" => _, "commit_message" => _} = params) do
    text conn, inspect Gittp.Git.write(:git, params)      
  end
end
