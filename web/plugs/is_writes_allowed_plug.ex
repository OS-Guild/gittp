defmodule Gittp.Web.Plugs.IsWritesAllowedPlug do
   import Plug.Conn

   def validate_writes_allowed(conn, _) do
        is_writes_allowed?(conn, System.get_env("ALLOW_WRITES"))
   end

   defp is_writes_allowed?(conn, "true"), do: conn 
   defp is_writes_allowed?(conn, _), do: conn |> send_resp(403, "Forbidden ") |> halt
end