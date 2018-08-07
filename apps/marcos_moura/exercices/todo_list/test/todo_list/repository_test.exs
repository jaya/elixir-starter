defmodule TodoList.BuilderTest do
  use ExUnit.Case

  import TodoList.Repository, only: [build: 2, complete: 2]

  test "build a todo with id" do
    todo = build(%{}, 1)
    assert todo[:id] == "C4CA4238A0B923820DCC509A6F75849B"
  end

  test "build a todo with created-at" do
    todo = build(%{}, 1)
    refute todo[:created_at] == nil
  end

  test "complete the second item from the list" do
    input = [%{id: :one, completed: false},
             %{id: :two, completed: false}]
    output = [%{id: :one, completed: false},
              %{id: :two, completed: true}]

    assert complete(:two, input) == output
  end
end
