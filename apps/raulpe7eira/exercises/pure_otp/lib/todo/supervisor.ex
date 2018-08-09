defmodule TODO.Supervisor do
  @moduledoc """
  The Supervisor is responsible for keeping a TODO started.
  """

  @doc """
  Starts the Supervisor.
  """
  def start do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :init, []
        Process.register pid, __MODULE__
        IO.puts "~> Supervisor is started."
      pid when is_pid(pid) ->
        IO.puts "~> Supervisor is already starting."
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
      {:EXIT, _from, _reason} ->
        IO.puts "~> Supervisor: ops... TODO?!"
        TODO.init()
        IO.puts "~> Supervisor: restarted TODO."
        supervising_todo()
    end
  end
end
