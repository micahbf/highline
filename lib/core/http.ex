defmodule Highline.Core.Http do
  @moduledoc """
  Provides an interface to the Slack HTTP API.
  """

  use Tesla, docs: false

  plug(Tesla.Middleware.BaseUrl, "https://slack.com/api")
  plug(Tesla.Middleware.Headers, [{"Authorization", "Bearer " <> slack_token()}])
  plug(Tesla.Middleware.JSON)

  @doc """
  Calls the [apps.connections.open](https://api.slack.com/methods/apps.connections.open) method
  to retrieve a Socket Mode WebSocket URL. Returns the WebSocket URL if successful.
  """
  @spec get_connection_url() :: {:ok, String.t()} | {:error, any()}
  def get_connection_url do
    case post("/apps.connections.open", "") do
      {:ok, %{status: 200, body: body}} -> {:ok, body["url"]}
      {:ok, response} -> {:error, response}
      error -> error
    end
  end

  @spec slack_token() :: String.t()
  defp slack_token do
    Application.fetch_env!(:highline, :slack_token)
  end
end
