defmodule TODO.ServerTest do
  use ExUnit.Case, async: true
  doctest TODO.Server
  @moduletag :server

  setup do
    server = start_supervised! TODO.Server
    task = %{completed: false, title: "tst-0"}

    %{server: server, task: task}
  end

  describe "TODO.Server.add/1" do
    test "expected: a created task", context do
      response = TODO.Server.add context.server, context.task

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      refute Map.has_key? response, :completed_at
    end

    test "expected: a error for task already created", context do
      TODO.Server.add context.server, context.task
      response = TODO.Server.add context.server, context.task

      assert response == %{error: "task already created"}
    end
  end

  describe "TODO.Server.list/0" do
    test "expected: a empty list", context do
      response = TODO.Server.list context.server

      assert is_list response
      assert length(response) == 0
    end

    test "expected: a populated list", context do
      TODO.Server.add context.server, context.task
      TODO.Server.add context.server, %{context.task | title: "tst-1"}
      response = TODO.Server.list context.server

      assert is_list response
      assert length(response) == 2
      for element <- response do
        assert is_map element
        assert Map.has_key? element, :id
        assert Map.has_key? element, :title
        assert Map.has_key? element, :completed
        refute Map.has_key? element, :created_at
        refute Map.has_key? element, :completed_at
      end
    end
  end

  describe "TODO.Server.complete/1" do
    test "expected: a updated task", context do
      id = TODO.Server.add(context.server, context.task)
      |> Map.fetch!(:id)

      response = TODO.Server.complete context.server, id

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      assert Map.has_key? response, :completed_at
      assert Map.fetch!(response, :completed) == true
    end

    test "expected: a error for task already completed", context do
      id = TODO.Server.add(context.server, context.task)
      |> Map.fetch!(:id)
      
      TODO.Server.complete context.server, id
      response = TODO.Server.complete context.server, id

      assert response == %{error: "task already completed"}
    end
  end
end
