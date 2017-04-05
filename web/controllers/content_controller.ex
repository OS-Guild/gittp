defmodule Gittp.ContentController do
  use Gittp.Web, :controller

  def read(conn, %{"path" => path}) do
    text conn, Gittp.Git.content(:git, "/Users/itaymaoz/Documents/" <> path)
  end
end
