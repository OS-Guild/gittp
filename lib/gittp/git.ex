defmodule Gittp.Git do
    use GenServer
    require Logger
    @interval 120 * 1000

    # client functions

    def start_link({:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}) do
        GenServer.start_link(__MODULE__, [{:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}], name: :git)
    end

    def content(server, path) do
        GenServer.call(server, {:read, path})
    end

    def write(server, body = %{"content" => content, "checksum" => checksum, "path" => path, "commit_message" => commit_message}) do
        GenServer.call(server, {:write, body})
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

    def handle_call({:read, path}, _from, repo) do        
        {:reply, Gittp.Repo.content(repo, path), repo}
    end

    def handle_call({:write, %{"content" => content, "checksum" => checksum, "path" => file_path, "commit_message" => commit_message}}, _from, repo) do     
        case checksum_valid?(checksum, repo, file_path) do
            false -> {:reply, {:error, :checksum_mismatch}, repo}            
            _ -> Gittp.Repo.write(repo, file_path, content, commit_message)
        end
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