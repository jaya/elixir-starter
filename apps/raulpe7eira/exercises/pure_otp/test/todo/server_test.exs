defmodule TODO.ServerTest do
  use ExUnit.Case, async: true
  doctest TODO.Server
  @moduletag :server

  setup do
    server = start_supervised! TODO.Server
    task = %{ completed: false, title: "tst-0" }

    %{ server: server, task: task }
  end

  describe "TODO.add/1" do
    test "expected: a created task", context do
      response = TODO.Server.add context.server, context.task

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
    end

    test "expected: a unchecked error for task already created", context do
      TODO.Server.add context.server, context.task
      response = TODO.Server.add context.server, context.task

      assert response == %{ error: "task already created" }
    end
  end

  describe "TODO.Server.list/0" do
    test "expected: a empty list", context do
      response = TODO.Server.list context.server

      assert response == []
    end

    test "expected: a populated list", context do
      TODO.Server.add context.server, context.task
      TODO.Server.add context.server, %{ context.task | title: "tst-1" }
      response = TODO.Server.list context.server

      assert length(response) == 2
    end
  end

  describe "TODO.complete/1" do
    test "expected: a updated task", context do
      id = TODO.Server.add(context.server, context.task) |> Map.fetch!(:id)
      response = TODO.Server.complete context.server, id

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      assert Map.has_key? response, :completed_at
      assert Map.fetch!(response, :completed) == true
    end

    test "expected: a unchecked error for task already completed", context do
      id = TODO.Server.add(context.server, context.task) |> Map.fetch!(:id)
      TODO.Server.complete context.server, id
      response = TODO.Server.complete context.server, id

      assert response == %{ error: "task already completed" }
    end
  end
end
