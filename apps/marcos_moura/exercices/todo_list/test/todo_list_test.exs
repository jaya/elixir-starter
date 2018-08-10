defmodule TodoListTest do
  use ExUnit.Case, async: true
  doctest TodoList

  setup do
    TodoList.start()

    {
      :ok,
      todo: %{title: "study otp", completed: false},
      first_todo: %{
        title: "study otp",
        completed: false,
        created_at: "2018-08-10",
        id: "C4CA4238A0B923820DCC509A6F75849B"
      },
      second_todo: %{
        title: "study spanw",
        completed: false,
        created_at: "2018-08-10",
        id: "C81E728D9D4C2F636F067F89CC14862C"
      },
      id: "C4CA4238A0B923820DCC509A6F75849B",
      id_2: "C81E728D9D4C2F636F067F89CC14862C"
    }
  end

  describe ".add()" do
    test "add a todo", fixture do
      TodoList.add(fixture[:todo])

      expectation = fixture[:first_todo]

      assert_receive ^expectation
    end

    test "does not allow duplicated todos titles", fixture do
      TodoList.add(fixture[:todo])
      TodoList.add(fixture[:todo])

      expectation = %{invalid: "task already created"}
      assert_receive ^expectation
    end
  end

  describe ".list()" do
    test "when there isn't todos" do
      TodoList.list()

      assert_receive []
    end

    test "when there is one todo", fixture do
      TodoList.add(fixture[:todo])
      TodoList.list()

      expectation = [fixture[:first_todo]]
      assert_receive ^expectation
    end

    test "when there are two todos", fixture do
      TodoList.add(fixture[:todo])
      TodoList.add(%{fixture[:todo] | title: "study spanw"})
      TodoList.list()

      expectation = [fixture[:second_todo], fixture[:first_todo]]
      assert_receive ^expectation
    end
  end

  describe ".completed()" do
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

    test "does not allow completion of already completed tasks", fixture do
      TodoList.add(fixture[:todo])
      TodoList.completed(fixture[:id])
      TodoList.completed(fixture[:id])

      expectation = %{invalid: "task already completed"}
      assert_receive ^expectation
    end
  end

  test "full cenario", fixture do
    TodoList.add(fixture[:todo])
    expectation = fixture[:first_todo]
    assert_receive ^expectation

    second = %{fixture[:todo] | title: "study spanw"}
    TodoList.add(second)
    second_todo = fixture[:second_todo]
    assert_receive ^second_todo

    TodoList.list()
    expectation = [fixture[:second_todo], fixture[:first_todo]]
    assert_receive ^expectation

    TodoList.completed(fixture[:id_2])
    expectation = %{fixture[:second_todo] | completed: true}
    assert_receive ^expectation

    TodoList.completed(fixture[:id_2])
    expectation = %{invalid: "task already completed"}
    assert_receive ^expectation

    TodoList.list()
    second_todo = %{fixture[:second_todo] | completed: true}
    expectation = [second_todo, fixture[:first_todo]]
    assert_receive ^expectation
  end

  @tag :pending
  test "supervisor" do
  end
end
