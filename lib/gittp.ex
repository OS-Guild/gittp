defmodule Gittp do
  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, args) do
    import Supervisor.Spec
    repo_address = List.first(args) || System.get_env("REMOTE_REPO_PATH") 
    local_repo_path = System.get_env("LOCAL_REPO_PATH")
    Logger.info("repo address is " <> repo_address)
    Logger.info("local path is " <> local_repo_path)
    # Define workers and child supervisors to be supervised
    children = [
      worker(Gittp.Web.Plugs.AuthorizedKeysCache, []),
      
      # Start the endpoint when the application starts
      supervisor(Gittp.Endpoint, []),
      # Start your own worker by calling: Gittp.Worker.start_link(arg1, arg2, arg3)
      
      worker(Gittp.Git, 
        local_repo_path: local_repo_path, 
        remote_repo_url: repo_address)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gittp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Gittp.Endpoint.config_change(changed, removed)
    :ok
  end
end
