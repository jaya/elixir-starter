defmodule TodoList do
  @moduledoc """
  A TodoList using processes
  """

  def start() do
    spawn_link(__MODULE__, :loop, [[]])
      |> Process.register(__MODULE__)
  end

  def loop(list) do
    receive do
      {:add, todo, caller} ->
        send(caller, todo)
        loop([todo | list])
      {:list, caller} ->
        send(caller, list)
        loop(list)
      {:completed, _id, caller} ->
        #TODO, find todo by id
        [todo | _] = list
        completed = %{todo | completed: true}
        send(caller, completed)
        loop([completed])
    after
      500 -> "nothing received"
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
