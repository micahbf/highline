import Config

config :tesla, adapter: Tesla.Adapter.Hackney
config :highline, slack_token: System.get_env("SLACK_APP_TOKEN")
