defmodule Gittp.Git do
    use GenServer
    require Logger
    import Gittp.Commit
    @interval 120 * 1000

    # client functions

    def start_link({:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}) do
        GenServer.start_link(__MODULE__, [{:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}], name: :git)
    end

    def write(server, body = %Gittp.Commit{content: content, checksum: checksum, path: path, commit_message: commit_message}) do
        GenServer.call(server, {:write, body}, 20000)
    end
    
    def create(server, body = %Gittp.Commit{content: content, path: path, commit_message: commit_message}) do
        GenServer.call(server, {:create, body}, 20000)
    end

    # server functions

    def init(local_repo_path: local_repo_path, remote_repo_url: remote_repo_url) do
        repo = case File.exists?(local_repo_path) do
                  false -> Gittp.Repo.clone(remote_repo_url, local_repo_path)
                      _ -> Gittp.Repo.from_local(local_repo_path)
               end

        Process.send_after(self(), :pull, @interval) 
        {:ok, repo}
    end

    def handle_call({:write, commit = %Gittp.Commit{}}, _from, repo) do    
        {:reply, Gittp.Repo.write(repo, commit), repo}
    end

    def handle_call({:create, commit = %Gittp.Commit{}}, _from, repo) do
        {:reply, Gittp.Repo.create(repo, commit), repo}
    end 
    
    def handle_info(:pull, repo) do
        Git.pull repo
        Logger.info "pulled latest changes from upstream"

        Process.send_after(self(), :pull, @interval) 
        {:noreply, repo}
    end

    defp checksum_valid?(checksum, repo, file_path) do
        full_path = Gittp.Repo.full_path(repo, file_path)
        File.exists?(full_path) and Gittp.Utils.hash_file(full_path) == checksum
    end    
end