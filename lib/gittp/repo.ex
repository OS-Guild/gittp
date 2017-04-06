defmodule Gittp.Repo do
    require Logger

    def full_path(repo, file_path) do
        [repo.path, file_path]
        |> Path.join
        |> Path.expand
    end

    def content(repo, file_path) do
        path = full_path(repo, file_path)
        case File.dir? path do
            false -> file_content path
                _ -> dir_content path
        end
    end

    defp dir_content(path) do
        case File.ls path do
            {:ok, content} -> {:ok, %{"content" => content, 
                                       "path" => path, 
                                       "isDirectory" => true}}
            error -> error
        end
    end

    defp file_content(path) do
        case File.read path do
            {:ok, content} -> {:ok, %{"content" => content, 
                                      "checksum" => Gittp.Utils.hash_string(content), 
                                      "path" => path, 
                                      "isDirectory" => false}}
            error -> error
        end
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
end