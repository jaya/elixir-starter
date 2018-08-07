defmodule TodoListTest do
  use ExUnit.Case
  doctest TodoList

  setup do
    TodoList.start()

    {
      :ok,
      todo: %{title: "study otp", completed: false},
      id: "1",
      id_2: "2"
    }
  end

  test ".add", fixture do
    TodoList.add(fixture[:todo])
    expectation = Map.put(fixture[:todo], :id, fixture[:id])

    assert_receive expectation
  end

  test ".list empty" do
    TodoList.list()

    assert_receive []
  end

  test ".list with one item", fixture do
    TodoList.add(fixture[:todo])
    TodoList.list()

    expectation = Map.put(fixture[:todo], :id, fixture[:id])
    assert_receive [expectation]
  end

  test ".list with two items", fixture do
    TodoList.add(fixture[:todo])
    TodoList.add(%{fixture[:todo] | title: "study spanw"})
    TodoList.list()

    assert_receive [%{title: "study spanw", completed: false},
                   %{title: "study otp", completed: false}]
  end

  test "Mark first todo as completed", fixture do
    TodoList.add(fixture[:todo])
    TodoList.completed(fixture[:id])

    expectation = %{fixture[:todo] | completed: true}
                    |> Map.put(:id, fixture[:id])

    assert_receive expectation
  end

  test "Mark second todo as completed", fixture do
    TodoList.add(fixture[:todo])
    second = %{fixture[:todo] | title: "study to be completed"}
    TodoList.add(second)
    TodoList.completed(fixture[:id_2])

    expectation = %{second | completed: true}

    assert_receive expectation
  end
end
