defmodule Chap15Test do
  use ExUnit.Case
  doctest Chap15

  test "greets the world" do
    assert Chap15.hello() == :world
  end
end
