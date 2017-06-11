defmodule Gittp.Web.Plugs.IsWritesAllowedPlug do
   import Plug.Conn

   def init(_), do: System.get_env("ALLOW_WRITES")

   def call(conn, "true"), do: conn
   def call(conn, _), do: conn |> send_resp(403, "Forbidden ") |> halt
end