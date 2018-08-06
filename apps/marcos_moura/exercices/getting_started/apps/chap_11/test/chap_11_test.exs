defmodule Chap11Test do
  use ExUnit.Case
  doctest Chap11

  test "greets the world" do
    assert Chap11.hello() == :world
  end
end
