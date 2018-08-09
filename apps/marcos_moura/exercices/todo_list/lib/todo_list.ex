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
        Repository.valid?(todo, list)
          |> create!(todo, list, caller)
          |> loop
      {:list, caller} ->
        send(caller, list)
        loop(list)
      {:completed, id, caller} ->
        Repository.completed?(id, list)
          |> complete!(id, list, caller)
          |> loop
      {:show, id, list, caller} ->
        todo = Repository.find(id, list)

        send(caller, todo)
        loop(list)
      {:invalid, message, caller} ->
        send(caller, %{invalid: message})
        loop(list)
    after
      50_000 -> :no_messages
    end
  end

  @doc """
  Add a to-do
  """
  def add(todo) do
    send(__MODULE__, {:add, todo, self()})
  end

  defp create!(false, todo, list, caller) do
    send(__MODULE__, {:invalid, "task already created", caller})
    list
  end

  defp create!(true, todo, list, caller) do
    new_todo = Repository.build(todo, length(list)+1)

    send(caller, new_todo)
    [new_todo | list]
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

  defp complete!(true, id, list, caller) do
    send(__MODULE__, {:invalid, "task already completed", caller})
    list
  end

  defp complete!(false, id, list, caller) do
    list = Repository.complete(id, list)
    send(__MODULE__, {:show, id, list, caller})
    list
  end
end
