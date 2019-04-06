use Mix.Config

config :bombadil, BombadilWeb.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [scheme: "https", host: "bombadil-api.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

config :bombadil, Bombadil.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :logger, level: :info
