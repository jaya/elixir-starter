defmodule TODO do
  use Application

  def start(_type, _args) do
    TODO.Supervisor.start_link name: TODO.Supervisor
  end

  def add(task) do
    TODO.Server.add task
  end

  def list() do
    TODO.Server.list
  end

  def complete(id) do
    TODO.Server.complete id
  end
end
