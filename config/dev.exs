import Config

config :tesla, adapter: Tesla.Adapter.Hackney

config :highline,
  slack_app_token: System.get_env("SLACK_APP_TOKEN"),
  slack_bot_token: System.get_env("SLACK_BOT_TOKEN")
