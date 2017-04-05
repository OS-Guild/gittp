defmodule Gittp.Git do
    use GenServer
    import Git


    # client functions

    def start_link({:repo_base_path, repo_base_path}) do
        GenServer.start_link(__MODULE__, repo_url: repo_url, name: :git)
    end

    def content(pid, path) do
        GenServer.call(pid, {:read, path})
    end

    def write(pid, path: path, content: content) do
        GenServer.call(pid, {:write, [file_path: path, content: content]})
    end

    # server functions

    def init({:repo_base_path, repo_base_path}) do
        {:ok, {:repo_base_path, repo_base_path}}
    end

    def handle_call({:read, path}, _from, {:repo_base_path, repo_base_path}) do
        case File.read repo_base_path <> path do
            {:ok, content} -> {:reply, content, []}
            {:error, message} -> {:reply, message, []}    
        end 
    end

    def handle_call({:write, [file_path: file_path, content: content]}, _from, {:repo_base_path, repo_base_path}) do        
        case File.write repo_base_path <> file_path, content do
            :ok -> 
                repo = Git.new repo_base_path                
                Git.add repo, "."
                Git.commit repo, ["-m", "my message"]
                {:reply, :ok, []}

            error -> {:reply, error, []}    
        end 
    end
end