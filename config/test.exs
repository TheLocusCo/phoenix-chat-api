use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_chat, PhoenixChat.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
# config :logger, backends: [:console], compile_time_purge_level: :debug

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

# Configure your database
config :phoenix_chat, PhoenixChat.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "locuscorev2",
  password: "locuscorev2",
  database: "phoenix_chat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :phoenix_chat, PhoenixChat.Mailer,
  adapter: Bamboo.TestAdapter
