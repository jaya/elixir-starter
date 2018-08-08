defmodule SendAndReceiveTest do
  use ExUnit.Case

  import Chap11.SendAndReceive, only: [ch_receive: 0]

  test "without message on mailbox" do
    assert ch_receive() == "nothing on mailbox"
  end

  test "ch_receive" do
    send self(), {:ola}
    assert ch_receive() == "hello without PID"
  end

  test "receive from parent" do
    send self(), {:ola, self()}
    assert ch_receive() == "hello with PID #{inspect self()}"
  end
end
