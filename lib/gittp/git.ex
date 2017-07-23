defmodule Gittp.Git do
    use GenServer
    require Logger
    @interval 120 * 1000

    # client functions

    def start_link({:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}) do
        GenServer.start_link(__MODULE__, [{:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}], name: :git)
    end

    def write(server, %Gittp.Commit{content: _, checksum: _, path: _, commit_message: _} = body) do
        GenServer.call(server, {:write, body}, 60_000)
    end
    
    def create(server, %Gittp.Commit{content: _, path: _, commit_message: _} = body) do
        GenServer.call(server, {:create, body}, 60_000)
    end

    # server functions
    def init(local_repo_path: local_repo_path, remote_repo_url: remote_repo_url) do
        repo = case File.exists?(local_repo_path) do
                  false -> Gittp.Repo.clone(remote_repo_url, local_repo_path)
                      _ -> Gittp.Repo.from_local(local_repo_path)
               end
        

        Gittp.Cache.start_link(local_repo_path)

        Process.send_after(self(), :pull, @interval) 
        {:ok, repo}
    end

    def handle_call({:write, commit = %Gittp.Commit{}}, _from, repo) do    
        result = Gittp.Repo.write(repo, commit)
        finish_write_operation(result, repo)
    end

    def handle_call({:create, commit = %Gittp.Commit{}}, _from, repo) do
        result = Gittp.Repo.create(repo, commit)
        finish_write_operation(result, repo)
    end 

    defp finish_write_operation({:error, _} = result, repo), do: {:reply, result, repo}

    defp finish_write_operation(result, repo) do
        GenServer.cast(self(), {:refresh})
        {:reply, result, repo}
    end

    def handle_cast({:refresh}, repo) do
        refresh_repo(repo)        
        {:noreply, repo}
    end
    
    def handle_info(:pull, repo) do
        refresh_repo(repo)
        Process.send_after(self(), :pull, @interval) 
        {:noreply, repo}
    end 

    defp refresh_repo(repo) do
        Git.pull repo
        Logger.info "pulled latest changes from upstream"

        Gittp.Cache.refresh repo.path
    end
end
