defmodule Ping do
  def start_link do
    spawn_link __MODULE__, :loop, []
  end

  def loop() do
    receive do
      {:ping, sender} ->
        send sender, :pong
      _ -> 
        :erlang.error(:i_was_expecting_ping)
    end
  end

  def ping(pid) do
    send pid, {:ping, self()}
    receive do
      :pong -> "Ok, everything is fine!"
      _ -> :erlang.error(:server_did_not_reply_with_pong)
    end
  end
end
