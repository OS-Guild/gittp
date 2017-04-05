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
            repo = Git.new local_repo_path
            Git.remote repo, ["add", "upstream", remote_repo_url]
            Git.pull repo, ~w(--rebase upstream master)
            Logger.info "pulled latest changes from " <> local_repo_path            
        else
            {:ok, repo} = Git.clone remote_repo_url
            Git.remote repo, ["add", "upstream", remote_repo_url]    
            Logger.info "cloned " <> remote_repo_url     
        end    
        {:ok, {repo}}
    end

    def handle_call({:read, path}, _from, {repo}) do        
        Logger.info repo.path <> "/" <> path
        case File.read repo.path <> "/" <> path do
            {:ok, content} -> {:reply, content, []}
            {:error, message} -> {:reply, message, []}    
        end 
    end

    def handle_call({:write, [file_path: file_path, content: content]}, _from, {repo}) do     
        Logger.info "Writing"
        Logger.info repo.path <> "/" <> file_path
        
        case File.write repo.path <> "/" <> file_path, content do
            :ok -> 
                Git.add repo, "."
                Git.commit repo, ["-m", "my message"]
                {:reply, :ok, []}

            error -> {:reply, error, []}    
        end 
    end
end