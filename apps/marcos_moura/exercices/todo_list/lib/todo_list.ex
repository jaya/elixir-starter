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
        list = if Repository.valid?(todo, list) do
          new_todo = Repository.build(todo, Enum.count(list)+1)

          send(caller, new_todo)
          [new_todo | list]
        else
          send(__MODULE__, {:error, "task already created", caller})
          list
        end
        loop(list)
      {:list, caller} ->
        send(caller, list)
        loop(list)
      {:completed, id, caller} ->
        #TODO, validation of already completed tasks
        list = if Repository.completed?(id, list) do
          send(__MODULE__, {:error, "task already completed", caller})
          list
        else
          list = Repository.complete(id, list)
          send(__MODULE__, {:show, id, list, caller})
          list
        end
        loop(list)
      {:show, id, list, caller} ->
        todo = Repository.find(id, list)

        send(caller, todo)
        loop(list)
      {:error, message, caller} ->
        send(caller, %{error: message})
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
