defmodule Highline.Core.Http do
  @moduledoc """
  Provides an interface to the Slack HTTP API.
  """

  @type response :: {:ok, %{String.t() => any()}} | {:error, any()}

  @doc """
  Calls the [apps.connections.open](https://api.slack.com/methods/apps.connections.open) method
  with the app token to retrieve a Socket Mode WebSocket URL.
  Returns the WebSocket URL if successful.
  """
  @spec get_connection_url() :: {:ok, String.t()} | {:error, any()}
  def get_connection_url do
    Tesla.post(with_app_token(), "/apps.connections.open", "")
    |> format_response
    |> case do
      {:ok, %{"url" => url}} -> {:ok, url}
      error -> error
    end
  end

  @doc """
  Sends a GET request to the given API method, authorized with the bot token.

  ## Examples

      get("conversations.list")
      {:ok,
        %{
          "channels" => [
            %{
            "created" => 1637518570,
            "creator" => "U02NH5KTRPB",
            "id" => "C02MPT43RPH",
            "is_archived" => false,
            "is_channel" => true,
            ...
  """
  @spec get(method :: String.t(), opts :: [Tesla.option()]) :: response()
  def get(method, opts \\ []) do
    path = "/" <> method

    Tesla.get(with_bot_token(), path, opts)
    |> format_response()
  end

  @doc """
  Sends a POST request to the given API method, authorized with the bot token.
  The supplied body will be encoded as JSON before being sent to the API.

  ## Examples

      post("chat.postMessage", %{channel: "C02MPT43RPH", text: "howdy!"})
      {:ok,
        %{
          "channel" => "C02MPT43RPH",
          "message" => %{
            "bot_id" => "B02MXU1NX6J",
            ...
  """
  @spec post(method :: String.t(), body :: Tesla.Env.body(), opts :: [Tesla.option()]) ::
          response
  def post(method, body, opts \\ []) do
    path = "/" <> method

    Tesla.post(with_bot_token(), path, body, opts)
    |> format_response()
  end

  @spec format_response(Tesla.Env.result()) :: {:ok, term()} | {:error, any()}
  defp format_response(response) do
    case response do
      {:ok, %{body: %{"ok" => true} = body}} -> {:ok, body}
      {:ok, %{body: %{"ok" => false, "error" => error}}} -> {:error, error}
      {:ok, response} -> {:error, response}
      {:error, error} -> {:error, error}
    end
  end

  @base_middleware [
    {Tesla.Middleware.BaseUrl, "https://slack.com/api"},
    {Tesla.Middleware.JSON, encode_content_type: "application/json; charset=utf-8"}
  ]

  @spec with_app_token :: Tesla.Client.t()
  defp with_app_token() do
    Tesla.client([auth_middleware(slack_app_token()) | @base_middleware])
  end

  @spec with_bot_token :: Tesla.Client.t()
  defp with_bot_token() do
    Tesla.client([auth_middleware(slack_bot_token()) | @base_middleware])
  end

  @spec auth_middleware(slack_token :: String.t()) :: Tesla.Client.middleware()
  defp auth_middleware(slack_token) do
    {Tesla.Middleware.Headers, [{"Authorization", "Bearer " <> slack_token}]}
  end

  @spec slack_app_token() :: String.t()
  defp slack_app_token do
    Application.fetch_env!(:highline, :slack_app_token)
  end

  @spec slack_bot_token() :: String.t()
  defp slack_bot_token do
    Application.fetch_env!(:highline, :slack_bot_token)
  end
end
