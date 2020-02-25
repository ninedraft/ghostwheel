import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

defmodule GhostConfig do
  def enable_proxy(addr) do
    [host, port | _] = String.split(addr, ":")

    config :nadia,
      proxy: {:socks5, String.to_charlist(host), port}
  end
end

case System.get_env("GHOSTWHEEL_PROXY") do
  nil -> nil
  addr -> GhostConfig.enable_proxy(addr)
end

config :nadia,
  token: {:system, "GHOSTWHEEL_TOKEN"}
