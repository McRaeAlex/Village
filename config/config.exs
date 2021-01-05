# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :village,
  ecto_repos: [Village.Repo]

# Configures the endpoint
config :village, VillageWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8CNCwIR5Ur4JXxOol/XlSxwbjpzt5OJvEJ348tO9CPqCCsRc0uEhYrDxgQPB/gxr",
  render_errors: [view: VillageWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Village.PubSub,
  live_view: [signing_salt: "t6XwCIEw"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use pow
config :village, :pow,
  user: Village.Accounts.User,
  repo: Village.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
