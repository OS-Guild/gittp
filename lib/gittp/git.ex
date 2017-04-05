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

    def write(pid, body = %{"content" => content, "checksum" => checksum, "path" => path}) do
        GenServer.call(pid, {:write, body})
    end

    # server functions

    def init([{:local_repo_path, local_repo_path}, {:remote_repo_url, remote_repo_url}]) do
        repo = if File.exists?(local_repo_path) do
                    repo = Git.new local_repo_path
                    Git.remote repo, ["add", "upstream", remote_repo_url]
                    Git.pull repo, ~w(--rebase upstream master)
                    Logger.info "pulled latest changes from " <> local_repo_path            
                    repo
                else
                    {:ok, repo} = Git.clone [remote_repo_url, local_repo_path]
                    Git.remote repo, ["add", "upstream", remote_repo_url]    
                    Logger.info "cloned " <> remote_repo_url     
                    repo
                end    
        
        {:ok, {repo}}
    end

    def handle_call({:read, path}, _from, {repo}) do        
        case File.read repo.path <> "/" <> path do
            {:ok, content} -> {:reply, %{"content" => content, "checksum" => Gittp.Utils.hash_string(content), "path" => path}, {repo}}
            {:error, message} -> {:reply, message, {repo}}    
        end 
    end

    def handle_call({:write, %{"content" => content, "checksum" => checksum, "path" => file_path}}, _from, {repo}) do     
        case File.write repo.path <> "/" <> file_path, content do
            :ok -> 
                Git.add repo, "."
                Git.commit repo, ["-m", "my message"]
                case Git.pull repo do
                    {:ok, _} -> 
                        case Git.push repo do 
                            {:ok, _} -> {:reply, :ok, {repo}}
                            {:error, reason} -> 
                                Git.reset repo, ~w(--hard HEAD~1)
                                {:reply, {:error, reason}, {repo}}
                        end

                    {:error, reason} -> 
                        Git.reset repo, ~w(--hard HEAD~1)
                        {:reply, reason, {repo}}

                end
            error -> {:reply, error, {repo}}    
        end 
    end
end