defmodule Chap10Test do
  use ExUnit.Case
  doctest Chap10

  test "greets the world" do
    assert Chap10.hello() == :world
  end
end
