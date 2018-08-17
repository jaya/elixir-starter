defmodule TODO.TaskTest do
  use ExUnit.Case, async: true
  doctest TODO.Task
  @moduletag :task

  setup do
    title = "tst-0"
    completed = false

    %{title: title, completed: completed}
  end

  describe "TODO.Task.create/2" do
    test "expected: a created task", context do
      response = TODO.Task.create context.title, context.completed

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      assert Map.has_key? response, :completed_at
    end
  end

  describe "TODO.Task.complete/1" do
    test "expected: a completed task", context do
      task = TODO.Task.create context.title, context.completed
      response = TODO.Task.complete task

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      assert Map.has_key? response, :completed_at
    end
  end

end
