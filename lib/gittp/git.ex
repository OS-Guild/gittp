defmodule Gittp.Git do
    use GenServer
    @repo_base_path "/Users/guy/guy-personal/dev/repo-example/"
    import Git


    # client functions

    def start_link do
        GenServer.start_link(__MODULE__, :ok, name: :git)
    end

    def content(pid, path) do
        GenServer.call(pid, {:read, path})
    end

    def write(pid, path: path, content: content) do
        GenServer.call(pid, {:write, [file_path: path, content: content]})
    end

    # server functions

    def init(:ok) do
        {:ok, []}
    end

    def handle_call({:read, path}, _from, _) do
        case File.read @repo_base_path <> path do
            {:ok, content} -> {:reply, content, []}
            {:error, message} -> {:reply, message, []}    
        end 
    end

    def handle_call({:write, [file_path: file_path, content: content]}, _from, _) do        
        case File.write @repo_base_path <> file_path, content do
            :ok -> 
                #repo = Git.new "/Users/guy/guy-personal/dev/repo-example"
                repo = Git.new @repo_base_path                
                Git.add repo, "."
                Git.commit repo, ["-m", "my message"]
                {:reply, :ok, []}

            error -> {:reply, error, []}    
        end 
    end
end