defmodule Gittp.Git do
    use GenServer

    # client functions

    def start_link do
        GenServer.start_link(__MODULE__, :ok, name: :git)
    end

    def content(pid, path) do
        GenServer.call(pid, {:read, path})
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

end