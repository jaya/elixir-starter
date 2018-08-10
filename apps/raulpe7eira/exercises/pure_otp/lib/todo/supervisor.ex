defmodule TODO.Supervisor do
  @moduledoc """
  The Supervisor is responsible for keeping a TODO started.
  """

  require Logger

  @doc """
  Starts the Supervisor.
  """
  def start do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :init, []
        Process.register pid, __MODULE__
        Logger.debug("Supervisor/#{inspect(pid)}: is started")
      pid when is_pid(pid) ->
        Logger.debug("Supervisor/#{inspect(pid)}: is already starting")
    end
  end

  @doc """
  Initializes and starts a supervising a TODO.
  """
  def init do
    Process.flag :trap_exit, true
    TODO.init()
    supervising_todo()
  end

  defp supervising_todo do
    receive do
      {:EXIT, from, _reason} ->
        Logger.debug("Supervisor/#{inspect(System.get_pid())}: ops... TODO/#{inspect(from)} exited")
        pid = TODO.init()
        Logger.debug("Supervisor/#{inspect(System.get_pid())}: há!... TODO/#{inspect(pid)} restarted")
        supervising_todo()
    end
  end
end
