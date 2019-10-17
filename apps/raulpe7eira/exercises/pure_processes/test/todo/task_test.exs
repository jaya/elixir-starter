defmodule TODO.TaskTest do
  use ExUnit.Case, async: true
  doctest TODO.Task
  @moduletag :task

  describe "TODO.Task.create/3" do
    test "expected: a created task" do
      task = TODO.Task.create [], "tst-0", false

      assert is_map task

      assert Map.has_key? task, :id
      assert Map.has_key? task, :title
      assert Map.has_key? task, :completed
      assert Map.has_key? task, :created_at
      assert Map.has_key? task, :completed_at
    end

    test "expected: a unchecked error for task already created" do
      todo = [
        %TODO.Task{
          completed: false,
          completed_at: nil,
          created_at: "2018-08-09",
          id: "md5-2c6ae5e6e7537c4328eede6c5f99fd63",
          title: "tst-0"
        }
      ]

      assert TODO.Task.create(todo, "tst-0", false) == {:unchecked, "task already created"}
    end
  end

  describe "TODO.Task.complete/2" do
    test "expected: a updated task" do
      todo = [
        %TODO.Task{
          completed: false,
          completed_at: nil,
          created_at: "2018-08-09",
          id: "md5-2c6ae5e6e7537c4328eede6c5f99fd63",
          title: "tst-0"
        }
      ]

      task = TODO.Task.complete todo, "md5-2c6ae5e6e7537c4328eede6c5f99fd63"
      assert is_map task

      assert Map.has_key? task, :id
      assert Map.has_key? task, :title
      assert Map.has_key? task, :completed
      assert Map.has_key? task, :created_at
      assert Map.has_key? task, :completed_at

      assert Map.fetch!(task, :completed) == true
    end

    test "expected: a unchecked error for task already completed" do
      todo = [
        %TODO.Task{
          completed: true,
          completed_at: "2018-08-09",
          created_at: "2018-08-09",
          id: "md5-2c6ae5e6e7537c4328eede6c5f99fd63",
          title: "tst-0"
        }
      ]

      assert TODO.Task.complete(todo, "md5-2c6ae5e6e7537c4328eede6c5f99fd63") == {:unchecked, "task already completed"}
    end
  end
end
