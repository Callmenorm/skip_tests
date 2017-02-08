# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :skip_tests,
  ecto_repos: [SkipTests.Repo]

# Configures the endpoint
config :skip_tests, SkipTests.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yanXP7qLBUVrdAowMCcmUjxe5IZaV4dxKbgR4huGpYOZpGTR5ui2CpCDCqevCwgt",
  render_errors: [view: SkipTests.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SkipTests.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
