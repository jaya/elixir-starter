defmodule Chap11.SendAndReceive do

  def ch_receive do
    receive do
      {:ola} -> "hello without PID"
      {:ola, pid} -> "hello with PID #{inspect pid}"
    after
      0 -> "nothing on mailbox"
    end
  end
end
