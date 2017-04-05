defmodule Gittp.ContentController do
  use Gittp.Web, :controller

  def read(conn, %{"path" => path}) do
    text conn, Gittp.Git.content(:git, path)
  end

  def write(conn, %{"path" => path, "content" => content}) do
    text conn, inspect Gittp.Git.write(:git, path: path, content: content)      
  end
end
