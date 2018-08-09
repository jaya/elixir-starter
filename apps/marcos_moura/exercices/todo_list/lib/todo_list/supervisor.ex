defmodule TodoList.Supervisor do
  def start do
    spawn_link(__MODULE__, :init_children, [])
  end

  def init_children do
    Process.flag(:trap_exit, true)
    TodoList.start()
    loop()
  end

  def loop do
    receive do
      {:EXIT, _pid, message} ->
        IO.puts("supervisor exit restart, #{message}")
        init_children()
        loop()
    end
  end
end
