defmodule TODOTest do
  use ExUnit.Case, async: true
  doctest TODO
  @moduletag :todo

  import ExUnit.CaptureLog

  describe "TODO.init/0" do
    test "expected: a success message" do
      assert capture_log(fn ->
        TODO.init()
      end) =~ ~r/: is started/
    end

    test "expected: a error message" do
      assert capture_log(fn ->
        TODO.init()
        TODO.init()
      end) =~ ~r/: is already starting, shutdown first/
    end
  end

  describe "TODO.add/1" do
    @tag capture_log: true
    test "expected: a created task" do
      TODO.init()

      task = TODO.add %{completed: false, title: "tst-0"}

      assert is_map task

      assert Map.has_key? task, :id
      assert Map.has_key? task, :title
      assert Map.has_key? task, :completed
      assert Map.has_key? task, :created_at
    end

    @tag capture_log: true
    test "expected: a required error for title" do
      TODO.init()

      assert TODO.add(%{completed: false}) == %{error: "ops... title is required"}
    end

    @tag capture_log: true
    test "expected: a required error for completed" do
      TODO.init()

      assert TODO.add(%{title: "tst-0"}) == %{error: "ops... completed is required"}
    end

    @tag capture_log: true
    test "expected: a required error for title and completed" do
      TODO.init()

      assert TODO.add(%{}) == %{error: "ops... title and completed is required"}
    end

    @tag capture_log: true
    test "expected: a unchecked error for task already created" do
      TODO.init()

      task = %{completed: false, title: "tst-0"} 
      TODO.add task

      assert TODO.add(task) == %{error: "task already created"}
    end
  end

  describe "TODO.list/0" do
    @tag capture_log: true
    test "expected: a empty list" do
      TODO.init()

      assert TODO.list() == []
    end

    @tag capture_log: true
    test "expected: a populated list" do
      TODO.init()

      TODO.add %{completed: false, title: "tst-0"}
      TODO.add %{completed: false, title: "tst-1"}

      assert length(TODO.list()) == 2
    end
  end

  describe "TODO.complete/1" do
    @tag capture_log: true
    test "expected: a updated task" do
      TODO.init()

      id = TODO.add(%{completed: false, title: "tst-0"})
      |> Map.fetch!(:id)

      task = TODO.complete id
      assert is_map task

      assert Map.has_key? task, :id
      assert Map.has_key? task, :title
      assert Map.has_key? task, :completed
      assert Map.has_key? task, :created_at
      assert Map.has_key? task, :completed_at

      assert Map.fetch!(task, :completed) == true
    end

    @tag capture_log: true
    test "expected: a unchecked error for task already completed" do
      TODO.init()

      id = TODO.add(%{completed: false, title: "tst-0"})
      |> Map.fetch!(:id)

      TODO.complete id

      assert TODO.complete(id) == %{error: "task already completed"}
    end
  end

  describe "TODO.shutdown/0" do
    test "expected: a success message" do
      assert capture_log(fn ->
        TODO.init()
        TODO.shutdown()
      end) =~ ~r/: is shutdown/
    end
  end
end
