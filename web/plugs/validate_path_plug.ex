defmodule Gittp.Web.Plugs.ValidatePathPlug do
    require Logger

    def validate_path(conn, _) do        
        conn = Plug.Conn.fetch_query_params conn
        path = Map.get(conn.params, "path")

        case  is_valid?(path)  do
            false -> conn |> Plug.Conn.send_resp(400, "invalid path") |> Plug.Conn.halt
            true -> conn
        end
    end

    defp is_valid?(path) do
        !Enum.member? path, "~"
    end
end