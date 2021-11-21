defmodule Highline.Core.SocketMode do
  @moduledoc """
  Core implementation of a Socket Mode WebSocket connection
  """

  use WebSockex

  def open_new do
    {:ok, url} = Highline.Core.Http.get_connection_url()
    start_link(url, nil)
  end

  def close(pid) do
    WebSockex.cast(pid, :close)
  end

  def send_message(pid, body) do
    WebSockex.cast(pid, {:send_msg, body})
  end

  def start_link(url, state) do
    WebSockex.start_link(url, __MODULE__, state)
  end

  def handle_frame({:text, body}, state) do
    message = Jason.decode!(body)
    IO.puts("Received message: #{inspect(message)}")

    if envelope_id = message["envelope_id"] do
      ack = Jason.encode!(%{envelope_id: envelope_id})
      IO.puts("Sending acknowledgement: #{inspect(ack)}")
      {:reply, {:text, ack}, state}
    else
      {:ok, state}
    end
  end

  def handle_frame({type, msg}, state) do
    IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg)}")
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  def handle_cast(:close, state) do
    {:close, state}
  end

  def handle_cast({:send_msg, msg_body}, state) do
    payload = Jason.encode!(%{channel: "C02MPT43RPH", text: msg_body})
    {:reply, {:text, payload}, state}
  end
end
