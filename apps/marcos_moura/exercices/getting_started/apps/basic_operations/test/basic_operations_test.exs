defmodule BasicOperationsTest do
  use ExUnit.Case
  doctest BasicOperations

  test "greets the world" do
    assert BasicOperations.hello() == :world
  end

  test "list concat" do
    assert BasicOperations.list_concat() == [1, 2, 3, 4, 5, 6]
  end

  test "list sub" do
    assert BasicOperations.list_sub == [1, 3]
  end

  test "concat" do
    assert BasicOperations.concat("Hello ", "world") == "Hello world"
  end

  test "say hello" do
    assert BasicOperations.say_hello == "hello world"
  end
end
