defmodule Item do
  @enforce_keys [:id]
  defstruct [:id , :title , :completed , :created_at, :completed_at]
end

defmodule TodoList do
    @moduledoc """
    Pure OTP TodoList
  """

  def start() do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link(__MODULE__, :loop, [[]])
        Process.register pid, __MODULE__
      pid when is_pid(pid) ->
        IO.inspect "TodoList is already runing. Stop first."
    end
  end

  def add(title, completed) do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :add, title, completed}
    receive do
      {^ref, item} -> IO.inspect(item)
    after 100 ->
      IO.inspect " TodoList isn't running"
    end
  end

  def list() do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :list}
    receive do
      {^ref, todos} -> IO.inspect(todos)
    after 100 ->
      IO.inspect " TodoList isn't running"
    end
  end
  
  def update() do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :update}
    receive do
      {^ref, :updated} -> IO.inspect("The TodoList was updated")

    after 100 ->
      IO.inspect " TodoList isn't running"
    end
  end

  def stop() do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :stop}
    receive do
      {^ref, :ok} ->
        IO.inspect "TodoList stoped"
    after 100 ->
      IO.inspect "TodoList is already stoped"
    end
  end

  def complete(id) do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :complete, id}
    receive do
      {^ref, :ok} ->
        IO.inspect "Item completed"
    after 100 ->
      IO.inspect "TodoList isn't running"
    end
  end

  defp _complete_item(todos, completed_id, index \\ 0) when is_list(todos) do
    %{id: current_id} = Enum.at(todos, index)
  
    if current_id == completed_id  do
      completed_item = %{Enum.at(todos, index) | completed: true}
      IO.puts "ACHOU: #{completed_id}"
      List.update_at(todos, index, completed_item)
    else
      IO.puts "Passou pelo #{current_id} #{index}"
      _complete_item(todos, completed_id, index + 1)
    end
    
  end

  def loop(todos) do
    receive do
      {{sender, ref}, :add, title, completed} ->
        item = %Item{id: generate_id() , title: title, completed: completed, created_at: Date.utc_today |> to_string, completed_at: nil}
        send sender, {ref, item}
        apply __MODULE__, :loop, [[item|todos]]
      {{sender, ref}, :list} -> 
        send sender, {ref, todos}
        apply __MODULE__, :loop, [todos]
      {{sender, ref}, :stop} ->
        send sender, {ref, :ok}
      {{sender, ref},:update} ->
        send sender, {ref, :updated}
        apply __MODULE__, :loop, [todos]
      {{sender, ref},:complete, id} ->
        updated_todos = _complete_item(todos, id)
        send sender, {ref, :updated}
        apply __MODULE__, :loop, [updated_todos]
    end
  end

  def generate_id() do
    "md5-#{:crypto.hash(:md5, to_string(:rand.uniform)) |> Base.encode16(case: :lower)}"
  end

end
