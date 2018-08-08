defmodule StateTest do
  use ExUnit.Case

  import Chap11.State, only: [start_link: 0]

  test "start link" do
    {:ok, pid} = start_link()
    assert pid != nil
  end

  test "put" do
    {:ok, pid} = start_link()
    send(pid, {:put, 0, :one})
    send(pid, {:get, 0, self()})

    assert_receive :one
  end
end
