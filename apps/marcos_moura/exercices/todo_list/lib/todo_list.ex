defmodule TodoList do
  @moduledoc """
  A TodoList using processes
  """

  alias TodoList.Repository

  def start() do
    pid = spawn_link(__MODULE__, :loop, [[]])

    Process.register(pid, __MODULE__)
  end

  def loop(list) do
    receive do
      {:add, todo, caller} ->
        new_todo = Repository.build(todo, Enum.count(list)+1)

        send(caller, new_todo)
        loop([new_todo | list])
      {:list, caller} ->
        send(caller, list)
        loop(list)
      {:completed, id, caller} ->
        list = Repository.complete(id, list)
        todo = Repository.find(id, list)

        send(caller, todo)
        loop(list)
    after
      20_000 -> :no_messages
    end
  end

  @doc """
  Add a to-do
  """
  def add(todo) do
    send(__MODULE__, {:add, todo, self()})
  end

  @doc """
  List all to-do
  """
  def list() do
    send(__MODULE__, {:list, self()})
  end

  @doc """
  Mark todo as completed
  """
  def completed(id) do
    send(__MODULE__, {:completed, id, self()})
  end
end
