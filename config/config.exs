# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :missing_pieces,
  ecto_repos: [MissingPieces.Repo]

# Configures the endpoint
config :missing_pieces, MissingPieces.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IHL6r8qeoH3XHUXmgXDEBW++cjiKWghipwoYHI7D+h/1KoAeNp82OEezWNiNZF93",
  render_errors: [view: MissingPieces.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MissingPieces.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
