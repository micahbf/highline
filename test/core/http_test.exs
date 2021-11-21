defmodule Highline.Core.HttpTest do
  use ExUnit.Case
  alias Highline.Core.Http
  import Tesla.Mock

  describe "get/2" do
    @request_params %{method: :get, url: "https://slack.com/api/conversations.list"}
    @success_body %{"ok" => true, "channels" => [%{"id" => "foo"}]}
    @error_body %{"ok" => false, "error" => "not_allowed_token_type"}

    def get_successful_call do
      fn @request_params -> json(@success_body) end
    end

    def get_slack_error_call do
      fn @request_params -> json(@error_body) end
    end

    def get_server_error_call do
      fn @request_params -> json(%{}, status: 500) end
    end

    test "returns {:ok, body} when the request is successful" do
      mock(get_successful_call())

      assert {:ok, body} = Http.get("conversations.list")
      assert body == @success_body
    end

    test "returns {:error, error} when the API returns an error" do
      mock(get_slack_error_call())
      assert {:error, "not_allowed_token_type"} = Http.get("conversations.list")
    end

    test "returns {:error, response} with a bad response from the server" do
      mock(get_server_error_call())
      assert {:error, %Tesla.Env{}} = Http.get("conversations.list")
    end
  end

  describe "get_connection_url/0" do
    @mock_ws_url "wss://wss-primary.slack.com/link/?ticket=abcd&app_id=abcd"
    @request_params %{method: :post, url: "https://slack.com/api/apps.connections.open"}

    def connection_successful_call do
      fn @request_params -> json(%{"ok" => true, "url" => @mock_ws_url}) end
    end

    def connection_failed_call do
      fn @request_params -> json(%{}, status: 500) end
    end

    test "returns {:ok, ws_url} when the call is successful" do
      mock(connection_successful_call())

      assert {:ok, @mock_ws_url} = Http.get_connection_url()
    end

    test "returns {:error, error} when the call fails" do
      mock(connection_failed_call())

      assert {:error, _} = Http.get_connection_url()
    end
  end

  describe "post/3" do
    @request_body %{"channel" => "abcd", "message" => "hello"}
    @request_params %{
      method: :post,
      url: "https://slack.com/api/chat.postMessage",
      body: Jason.encode!(@request_body)
    }
    @success_body %{"ok" => true, "message" => %{"text" => "hello"}}
    @error_body %{"ok" => false, "error" => "not_allowed_token_type"}

    def post_successful_call do
      fn @request_params -> json(@success_body) end
    end

    def post_slack_error_call do
      fn @request_params -> json(@error_body) end
    end

    def post_server_error_call do
      fn @request_params -> json(%{}, status: 500) end
    end

    test "returns {:ok, body} when the request is successful" do
      mock(post_successful_call())

      assert {:ok, body} = Http.post("chat.postMessage", @request_body)
      assert body == @success_body
    end

    test "returns {:error, error} when the API returns an error" do
      mock(post_slack_error_call())
      assert {:error, "not_allowed_token_type"} = Http.post("chat.postMessage", @request_body)
    end

    test "returns {:error, response} with a bad response from the server" do
      mock(post_server_error_call())
      assert {:error, %Tesla.Env{}} = Http.post("chat.postMessage", @request_body)
    end
  end
end
