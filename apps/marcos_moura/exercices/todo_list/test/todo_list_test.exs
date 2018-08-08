defmodule TodoListTest do
  use ExUnit.Case, async: true
  doctest TodoList

  setup do
    TodoList.start()

    {
      :ok,
      todo: %{title: "study otp", completed: false},
      first_todo: %{title: "study otp", completed: false, created_at: "2018-08-08", id: "C4CA4238A0B923820DCC509A6F75849B"},
      second_todo: %{title: "study spanw", completed: false, created_at: "2018-08-08", id: "C81E728D9D4C2F636F067F89CC14862C"},
      id: "C4CA4238A0B923820DCC509A6F75849B",
      id_2: "C81E728D9D4C2F636F067F89CC14862C"
    }
  end

  test "add a todo", fixture do
    TodoList.add(fixture[:todo])

    expectation = fixture[:first_todo]

    assert_receive ^expectation
  end

  test "list when there isn't todos" do
    TodoList.list()

    assert_receive []
  end

  test "list when there is one todo", fixture do
    TodoList.add(fixture[:todo])
    TodoList.list()

    expectation = [fixture[:first_todo]]
    assert_receive ^expectation
  end

  test "list when there are two todos", fixture do
    TodoList.add(fixture[:todo])
    TodoList.add(%{fixture[:todo] | title: "study spanw"})
    TodoList.list()


    expectation = [fixture[:second_todo], fixture[:first_todo]]
    assert_receive ^expectation
  end

  test "mark first todo as completed", fixture do
    TodoList.add(fixture[:todo])
    TodoList.completed(fixture[:id])

    expectation = %{fixture[:first_todo] | completed: true}

    assert_receive ^expectation
  end

  test "mark second todo as completed", fixture do
    TodoList.add(fixture[:todo])
    second = %{fixture[:todo] | title: "study spanw"}
    TodoList.add(second)
    TodoList.completed(fixture[:id_2])

    expectation = %{fixture[:second_todo] | completed: true}
    assert_receive ^expectation
  end

  @tag :wip
  test "validation to not allow duplicated todos titles", fixture do
    TodoList.add(fixture[:todo])
    TodoList.add(fixture[:todo])

    expectation = %{error: "task already created"}
    assert_receive ^expectation
  end

  @tag :pending
  test "validate to not allow completion of already completed tasks", fixture do
    TodoList.add(fixture[:todo])
    TodoList.completed(fixture[:id])
    TodoList.completed(fixture[:id])

    expectation = %{error: "task already completed"}
    assert_receive ^expectation
  end
end
