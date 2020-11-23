# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :planning_poker,
  ecto_repos: [PlanningPoker.Repo]

# Configures the endpoint
config :planning_poker, PlanningPokerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wRrAxd0lD4QAEe9vq5RQdDLrlncOFaHSTswJvKsNuMhxCMxf3Ygv7G5R+cp/PQ2n",
  render_errors: [view: PlanningPokerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PlanningPoker.PubSub,
  live_view: [signing_salt: "jzvHVL1h"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Set Timezone
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
