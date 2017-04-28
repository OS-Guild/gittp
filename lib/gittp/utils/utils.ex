defmodule Gittp.Utils do
    def hash_file(file) do
        file 
        |> File.stream!([], 2048) 
        |> Enum.reduce(:crypto.hash_init(:sha256), fn (line, acc) -> :crypto.hash_update(acc, line) end) 
        |> :crypto.hash_final 
        |> Base.encode16
    end

    def hash_string(string) do
        :sha256
        |> :crypto.hash(string) 
        |> Base.encode16
    end
end