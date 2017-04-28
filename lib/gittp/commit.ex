defmodule Gittp.Commit do
    defstruct content: "", checksum: "", path: "", commit_message: "", author: "system <system@gittp>"
    require Logger 

    def from(%{"path" => path, "content" => content, "commit_message" => commit_message} = params) do
        commit = %Gittp.Commit{path: path, content: content, commit_message: commit_message}                  
        if Map.has_key?(params, "author") do
            commit = %Gittp.Commit{commit | author: Map.get(params, "author")}
        end
        if Map.has_key?(params, "checksum") do
            commit = %Gittp.Commit{commit | checksum: Map.get(params, "checksum")}
        end 
        
        commit
    end
end