defmodule Gittp.Web.Plugs.AuthorizedKeysCache do
    def start_link do
        authorized_keys = 
            System.get_env("API_KEYS_FILE_PATH")
            |> File.stream!([:read, :utf8])
            |> Enum.reduce([], fn (current, list) -> [String.trim(current) | list] end)

        Agent.start_link(fn -> authorized_keys end, [name: __MODULE__])
    end

    def get do
        Agent.get(__MODULE__, fn keys -> keys end)
  end 
end 