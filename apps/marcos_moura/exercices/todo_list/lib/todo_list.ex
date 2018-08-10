defmodule TodoList do
  @moduledoc """
  A TodoList using processes
  """

  alias TodoList.Server

  def start() do
    pid = spawn_link(Server, :loop, [[]])

    Process.register(pid, Server)
  end

  @doc """
  Add a to-do
  """
  def add(todo) do
    send(Server, {:add, todo, self()})
  end

  @doc """
  List all to-do
  """
  def list() do
    send(Server, {:list, self()})
  end

  @doc """
  Mark todo as completed
  """
  def completed(id) do
    send(Server, {:completed, id, self()})
  end
end
