defmodule Gittp.Git do
    use GenServer

    # client functions

    def start_link do
        GenServer.start_link(__MODULE__, :ok, name: :git)
    end

    def content(pid, path) do
        GenServer.call(pid, {:read, path})
    end

    def write(pid, path: path, content: content) do
        GenServer.call(pid, {:write, path, content})
    end

    # server functions

    def init(:ok) do
        {:ok, []}
    end

    def handle_call({:read, path}, _from, _) do
        case File.read path do
            {:ok, content} -> {:reply, content, []}
            {:error, message} -> {:reply, message, []}    
        end 
    end

    def handle_call({:write, path, content}, _from, _) do
        case File.write path, content do
            :ok -> {:reply, :ok, []}
            error -> {:reply, error, []}    
        end 
    end
end