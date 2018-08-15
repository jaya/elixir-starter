defmodule TODO.ServerTest do
  use ExUnit.Case, async: true
  doctest TODO.Server
  @moduletag :server

  setup do
    server = start_supervised! TODO.Server
    %{server: server}
  end

  describe "TODO.add/1" do
    test "expected: a created task" do
      response = TODO.Server.add %{completed: false, title: "tst-0"}

      assert is_map response

      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at

      :ok = stop_supervised TODO.Server
    end

    test "expected: a unchecked error for task already created" do
      task = %{completed: false, title: "tst-0"} 
      TODO.Server.add task
      response = TODO.Server.add(task)
      assert response == %{error: "task already created"}

      :ok = stop_supervised TODO.Server
    end
  end

  describe "TODO.Server.list/0" do
    test "expected: a empty list", %{server: _server} do
      response = TODO.Server.list()
      assert response == []

      :ok = stop_supervised TODO.Server
    end

    test "expected: a populated list", %{server: _server} do
      TODO.Server.add %{completed: false, title: "tst-0"}
      TODO.Server.add %{completed: false, title: "tst-1"}
      response = TODO.Server.list()
      assert length(response) == 2

      :ok = stop_supervised TODO.Server
    end
  end

  describe "TODO.complete/1" do
    test "expected: a updated task" do
      id = TODO.Server.add %{completed: false, title: "tst-0"} |> Map.fetch!(:id)

      response = TODO.complete id
      assert is_map response

      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      assert Map.has_key? response, :completed_at

      assert Map.fetch!(response, :completed) == true

      :ok = stop_supervised TODO.Server
    end

    @tag capture_log: true
    test "expected: a unchecked error for task already completed" do
      id = TODO.add(%{completed: false, title: "tst-0"}) |> Map.fetch!(:id)

      TODO.complete id
      response = TODO.complete(id)

      assert response == %{error: "task already completed"}

      :ok = stop_supervised TODO.Server
    end
  end
end
