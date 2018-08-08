defmodule TODO.Supervisor do
  @moduledoc """
  """

  @doc """
  """
  def start_link do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :init, []
        Process.register pid, __MODULE__
        IO.puts "~> TODO_Supervisor is started."
      pid when is_pid(pid) ->
        IO.puts "TODO_Supervisor is already starting."
    end
  end

  @doc """
  """
  def init do
    Process.flag :trap_exit, true
    TODO.init()
    supervising_todo()
  end

  defp supervising_todo do
    receive do
      {:EXIT, _from, _reason} ->
        IO.puts "~> TODO Supervisor: TODO ops..."
        TODO.init()
        IO.puts "~> TODO Supervisor: TODO restarted."
        supervising_todo()
    end
  end
end
