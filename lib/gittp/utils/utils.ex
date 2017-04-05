defmodule Gittp.Utils do
    def hash_file(file) do
        File.stream!(file,[],2048) 
        |> Enum.reduce(:crypto.hash_init(:sha256), fn (line, acc) -> :crypto.hash_update(acc,line) end) 
        |> :crypto.hash_final 
        |> Base.encode16
    end

    def hash_string(string) do
        :crypto.hash(:sha256, string) |> Base.encode16
    end
end