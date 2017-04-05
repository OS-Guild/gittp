defmodule Gittp.Repo do
    def full_path(repo, file_path) do
        Path.join [repo.path, file_path]
    end

    def content(repo, file_path) do
        File.read full_path(repo, file_path)
    end

    def write(repo, file_path, content, commit_message) do
        case File.write full_path(repo, file_path), content do
                :ok -> 
                    Git.add repo, "."
                    Git.commit repo, ["-m", commit_message]
                    case Git.pull repo do
                        {:ok, _} -> 
                            case Git.push repo do 
                                {:ok, message} -> {:reply, message, repo}
                                {:error, message} -> 
                                    Git.reset repo, ~w(--hard HEAD~1)
                                    {:reply, {:error, message}, repo}
                            end

                        {:error, message} -> 
                            Git.reset repo, ~w(--hard HEAD~1)
                            {:reply, message, repo}

                    end
                error -> {:reply, error, repo}    
            end 
    end
end