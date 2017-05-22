defmodule Gittp do
  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec
    Logger.info(inspect _args)
    repo_address = List.first(_args) || System.get_env("REMOTE_REPO_PATH") 
    Logger.info("repo address is " <> repo_address);
    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Gittp.Endpoint, []),
      # Start your own worker by calling: Gittp.Worker.start_link(arg1, arg2, arg3)
      
      worker(Gittp.Git, 
        local_repo_path: Application.get_env(:gittp, Gittp.Endpoint)[:local_repo_path], 
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
