defmodule Gittp.Utils do
    def hash(file) do
        File.stream!(file,[],2048) 
        |> Enum.reduce(:crypto.hash_init(:sha256), fn (line, acc) -> :crypto.hash_update(acc,line) end) 
        |> :crypto.hash_final 
        |> Base.encode16
    end
end