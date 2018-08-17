defmodule TODO do
  use Application

  @impl true
  def start(_type, _args) do
    TODO.Supervisor.start_link name: TODO.Supervisor
  end

  def add(params) do
    TODO.Server.add TODO.Server, params
  end

  def list() do
    TODO.Server.list TODO.Server
  end

  def complete(id) do
    TODO.Server.complete TODO.Server, id
  end
end
