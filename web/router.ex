defmodule Gittp.Router do
  use Gittp.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Gittp do
    pipe_through :api # Use the default browser stack

    get "/content/:path", ContentController, :read
    post "/content/:path", ContentController, :write
    put "/content/:path", ContentController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", Gittp do
  #   pipe_through :api
  # end
end
