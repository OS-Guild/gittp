defmodule Gittp.ContentController do
  use Gittp.Web, :controller

  def read(conn, %{"path" => path}) do
    text conn, Gittp.Git.content(:git, "/Users/itaymaoz/Documents/" <> path)
  end

  def write(conn, %{"path" => path, "content" => content}) do
    text conn, Gittp.Git.write(:git, path: "/Users/itaymaoz/Documents/" <> path, content: content)      
  end
end
