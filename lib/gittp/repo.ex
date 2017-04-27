defmodule Gittp.Repo do
    require Logger

    def full_path(repo, file_path) do
        [repo.path, file_path]
        |> Path.join
        |> Path.expand
    end

    def content(repo, path) do
        case File.dir? path do
            false -> file_content repo, path
                _ -> dir_content repo, path
        end
    end

    def from_local(local_repo_path) do
        repo = Git.new local_repo_path
        Git.pull repo, ~w(--rebase upstream master)
        Logger.info "pulled latest changes from upstream" 
        repo
    end

    def clone(remote_repo_url, local_repo_path) do
        {:ok, repo} = Git.clone [remote_repo_url, local_repo_path]
        Git.remote repo, ["add", "upstream", remote_repo_url]    
        Logger.info "cloned " <> remote_repo_url
        repo
    end

    def write(repo, file_path, content, commit_message, checksum) do
        case checksum_valid?(repo, checksum, file_path) do
            false -> {:error, :checksum_mismatch}
            true -> write_and_push(repo, file_path, content, commit_message)   
        end
    end

    def create(repo, path, content, commit_message) do
        absolute_path = full_path(repo, path)
        {:ok, file} = File.open absolute_path, [:write]
        IO.write file, content
        File.close file
        commit_and_push(repo, commit_message)
    end

    defp dir_content(repo, path) do
        absolute_path = full_path(repo, path)        
        case File.ls absolute_path do
            {:ok, content} -> {:ok, %{"content" => content, 
                                       "path" => path, 
                                       "isDirectory" => true}}
            error -> error
        end
    end

    defp file_content(repo, path) do
        absolute_path = full_path(repo, path)                
        case File.read absolute_path do
            {:ok, content} -> {:ok, %{"content" => content, 
                                      "checksum" => Gittp.Utils.hash_string(content), 
                                      "path" => path, 
                                      "isDirectory" => false}}
            error -> error
        end
    end

    defp write_and_push(repo, file_path, content, commit_message) do
        case File.write full_path(repo, file_path), content do
            :ok -> commit_and_push(repo, commit_message)
            error -> {:reply, error, repo}    
        end
    end

    defp commit_and_push(repo, commit_message) do
        Git.add repo, "."
        Git.commit repo, ["-m", commit_message]
        case Git.pull repo do
            {:ok, _} -> case Git.push repo do 
                            {:ok, message} -> {:reply, message, repo}
                            {:error, message} ->
                                 Git.reset repo, ~w(--hard HEAD~1)
                                 {:reply, {:error, message}, repo}
                        end
            {:error, message} ->
                 Git.reset repo, ~w(--hard HEAD~1)
                {:reply, message, repo}
        end        
    end

    defp checksum_valid?(repo, checksum, file_path) do
        full_path = Gittp.Repo.full_path(repo, file_path)
        File.exists?(full_path) and Gittp.Utils.hash_file(full_path) == checksum
    end 
end