defmodule Highline.Core.HttpTest do
  use ExUnit.Case
  alias Highline.Core.Http
  import Tesla.Mock

  describe "get_connection_url/0" do
    @mock_ws_url "wss://wss-primary.slack.com/link/?ticket=abcd&app_id=abcd"
    @request_params %{method: :post, url: "https://slack.com/api/apps.connections.open"}

    def successful_call do
      fn @request_params -> json(%{"ok" => true, "url" => @mock_ws_url}) end
    end

    def failed_call do
      fn @request_params -> json(%{}, status: 500) end
    end

    test "returns {:ok, ws_url} when the call is successful" do
      mock(successful_call())

      assert {:ok, @mock_ws_url} = Http.get_connection_url()
    end

    test "returns {:error, error} when the call fails" do
      mock(failed_call())

      assert {:error, _} = Http.get_connection_url()
    end
  end
end
