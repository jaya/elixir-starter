defmodule TodoListTest do
  use ExUnit.Case
  doctest TodoList

  test "greets the world" do
    assert TodoList.hello() == :world
  end
end
