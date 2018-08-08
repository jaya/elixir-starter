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
        if Repository.valid?(todo, list) do
          new_todo = Repository.build(todo, Enum.count(list)+1)

          send(caller, new_todo)
          loop([new_todo | list])
        else
          send(caller, %{error: "task already created"})
          send(__MODULE__, {:error, "task already created", caller})
          loop(list)
        end
      {:list, caller} ->
        send(caller, list)
        loop(list)
      {:completed, id, caller} ->
        #TODO, validation of already completed tasks
        list = Repository.complete(id, list)

        send(__MODULE__, {:show, id, list, caller})
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
