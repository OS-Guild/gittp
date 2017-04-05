defmodule Gittp.Git do
    use GenServer
    require Logger
    # client functions

    def start_link({:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}) do
        GenServer.start_link(__MODULE__, [{:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}], name: :git)
    end

    def content(pid, path) do
        GenServer.call(pid, {:read, path})
    end

    def write(pid, path: path, content: content) do
        GenServer.call(pid, {:write, [file_path: path, content: content]})
    end

    # server functions

    def init([{:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}]) do
        if File.exists?(local_repo_path) do
            Logger.info "deleted local git repository from " <> local_repo_path
            File.rm_rf(local_repo_path)
        end
        {:ok, repo} = Git.clone remote_repo_url
        Logger.info "cloned " <> remote_repo_url     
        {:ok, {repo}}
    end

    def handle_call({:read, path}, _from, {repo}) do        
        Logger.info repo.path <> "/" <> path
        case File.read repo.path <> "/" <> path do
            {:ok, content} -> {:reply, content, {repo}}
            {:error, message} -> {:reply, message, {repo}}    
        end 
    end

    def handle_call({:write, [file_path: file_path, content: content]}, _from, {repo}) do     
        Logger.info "Writing"
        Logger.info repo.path <> "/" <> file_path
        
        case File.write repo.path <> "/" <> file_path, content do
            :ok -> 
                Git.add repo, "."
                Git.commit repo, ["-m", "my message"]
                {:reply, :ok, {repo}}

            error -> {:reply, error, {repo}}    
        end 
    end
end