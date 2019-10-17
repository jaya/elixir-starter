defmodule TODOTest do
  use ExUnit.Case, async: true
  doctest TODO
  @moduletag :todo

  setup do
    TODO.start :normal, []
    params = %{completed: false, title: "tst-0"}

    %{params: params}
  end

  describe "TODO.add/1" do
    test "expected: a created task", context do
      response = TODO.add context.params

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      refute Map.has_key? response, :completed_at
    end

    test "expected: a error message w/ 'task already created'", context do
      TODO.add context.params
      response = TODO.add context.params

      assert response == %{error: "task already created"}
    end
  end

  describe "TODO.list/0" do
    test "expected: a empty list" do
      response = TODO.list

      assert is_list response
      assert length(response) == 0
    end

    test "expected: a populated list", context do
      TODO.add context.params
      TODO.add %{context.params | title: "tst-1"}
      response = TODO.list

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

  describe "TODO.complete/1" do
    test "expected: a completed task", context do
      id = TODO.add(context.params).id
      response = TODO.complete id

      assert is_map response
      assert Map.has_key? response, :id
      assert Map.has_key? response, :title
      assert Map.has_key? response, :completed
      assert Map.has_key? response, :created_at
      assert Map.has_key? response, :completed_at
      assert response.completed == true
    end

    test "expected: a error message w/ 'task already completed'", context do
      id = TODO.add(context.params).id
      TODO.complete id
      response = TODO.complete id

      assert response == %{error: "task already completed"}
    end
  end

  describe "TODO[Supervisor.strategy: one_for_one]" do
    test "expected: the restarted server when it to die" do
      supervisor = Process.whereis TODO.Supervisor

      [{_id, child, _type, _modules} | _tail] = Supervisor.which_children supervisor

      assert child == Process.whereis TODO.Server

      Process.exit child, :kill
      Process.sleep 1

      assert child != Process.whereis TODO.Server
    end
  end
end
