defmodule TodoList.BuilderTest do
  use ExUnit.Case, async: true

  import TodoList.Repository, only: [build: 2, complete: 2, valid?: 2, completed?: 2]

  test "build a todo with id" do
    todo = build(%{}, 1)
    assert todo[:id] == "C4CA4238A0B923820DCC509A6F75849B"
  end

  test "build a todo with created-at" do
    todo = build(%{}, 1)
    refute todo[:created_at] == nil
  end

  test "complete the second item from the list" do
    input = [%{id: :one, completed: false}, %{id: :two, completed: false}]
    output = [%{id: :one, completed: false}, %{id: :two, completed: true}]

    assert complete(:two, input) == output
  end

  describe ".valid?" do
    test "when is invalid" do
      todo = %{title: 'test'}
      list = [todo]

      assert valid?(todo, list) == false
    end

    test "when is valid" do
      todo = %{title: 'test'}
      list = [%{title: 'other'}]

      assert valid?(todo, list) == true
    end
  end

  describe ".completed?" do
    test "when was already completed" do
      list = [%{id: 1, completed: true}]

      assert completed?(1, list) == true
    end

    test "when is not completed" do
      list = [%{id: 1, completed: false}]

      assert completed?(1, list) == false
    end
  end
end
