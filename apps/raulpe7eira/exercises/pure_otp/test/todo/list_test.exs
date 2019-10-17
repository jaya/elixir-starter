defmodule TODO.ListTest do
  use ExUnit.Case, async: true
  doctest TODO.List
  @moduletag :list

  setup do
    list = start_supervised! TODO.List
    title = "tst-0"
    completed = false

    %{list: list, title: title, completed: completed}
  end

  describe "TODO.List.create_task/3" do
    test "expected: a created task", context do
      {:ok, response} = TODO.List.create_task context.list, context.title, context.completed

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      assert Map.has_key? response, :completed_at
    end

    test "expected: a error message w/ 'task already created'", context do
      TODO.List.create_task context.list, context.title, context.completed
      {:error, response} = TODO.List.create_task context.list, context.title, context.completed

      assert response == "task already created"
    end
  end

  describe "TODO.List.tasks/1" do
    test "expected: a empty list", context do
      response = TODO.List.tasks context.list

      assert is_list response
      assert length(response) == 0
    end

    test "expected: a populated list", context do
      TODO.List.create_task context.list, context.title, context.completed
      TODO.List.create_task context.list, "tst-1", context.completed
      response = TODO.List.tasks context.list

      assert is_list response
      assert length(response) == 2
      for element <- response do
        assert is_map element
        assert Map.has_key? element, :id
        assert Map.has_key? element, :title
        assert Map.has_key? element, :completed
        assert Map.has_key? element, :created_at
        assert Map.has_key? element, :completed_at
      end
    end
  end

  describe "TODO.List.complete_task/2" do
    test "expected: a completed task", context do
      id = elem(TODO.List.create_task(context.list, context.title, context.completed), 1).id
      {:ok, response} = TODO.List.complete_task context.list, id

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      assert Map.has_key? response, :completed_at
      assert response.completed == true
    end

    test "expected: a error message w/ 'task already completed'", context do
      id = elem(TODO.List.create_task(context.list, context.title, context.completed), 1).id
      TODO.List.complete_task context.list, id
      {:error, response} = TODO.List.complete_task context.list, id

      assert response == "task already completed"
    end
  end
end
