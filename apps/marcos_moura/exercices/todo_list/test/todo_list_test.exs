defmodule TodoListTest do
  use ExUnit.Case
  doctest TodoList

  setup do
    TodoList.start()

    {:ok, todo: %{title: "study otp", completed: false}}
  end

  test ".add", fixture do
    TodoList.add(fixture[:todo])

    assert_receive %{title: "study otp", completed: false}
  end

  test ".list empty" do
    TodoList.list()

    assert_receive []
  end

  test ".list with one item", fixture do
    TodoList.add(fixture[:todo])
    TodoList.list()

    assert_receive [%{title: "study otp", completed: false}]
  end

  test ".list with two items", fixture do
    TodoList.add(fixture[:todo])
    TodoList.add(%{fixture[:todo] | title: "study spanw"})
    TodoList.list()

    assert_receive [%{title: "study spanw", completed: false},
                   %{title: "study otp", completed: false}]
  end

  test "Mark todo as completed", fixture do
    TodoList.add(fixture[:todo])
    TodoList.completed(1)

    assert_receive %{title: "study otp", completed: true}
  end
end
