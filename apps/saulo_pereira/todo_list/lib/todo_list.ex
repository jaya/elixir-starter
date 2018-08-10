defmodule Item do
  @enforce_keys [:id, :title]
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
      {^ref, :error, message} -> IO.inspect(message)
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
      {^ref, :completed} ->
        IO.inspect "Item completed"
      {^ref, :error, message} ->
        IO.inspect message
    after 100 ->
      IO.inspect "TodoList isn't running"
    end
  end

  defp _complete_item([%Item{id: id } = head | tail], id, new_todos) do
    if head.completed do
        {:error,"task already completed"}
      else
        _complete_item(tail, id, [%{head | completed: true, completed_at: Date.utc_today |> to_string} | new_todos])
    end
  end

  defp _complete_item([head | tail], id, new_todos) do
    _complete_item(tail, id, [head | new_todos])
  end

  defp _complete_item([], _id, new_todos) do
    {:ok, new_todos}
  end


  defp _check_if_title_exists([%Item{title: title } = _head | _tail], title) do
    true
  end

  defp _check_if_title_exists([_head | tail], title) do
    _check_if_title_exists(tail, title)
  end

  defp _check_if_title_exists([], _title) do
    false
  end

  def loop(todos) do
    receive do
      {{sender, ref}, :add, title, completed} ->
        if _check_if_title_exists todos, title do
          send sender, {ref, :error, "task already created"}
          callLoopAgain [todos]
        else
          item = %Item{id: generate_id() , title: title, completed: completed, created_at: Date.utc_today |> to_string, completed_at: nil}
          send sender, {ref, item}
          callLoopAgain [[item|todos]]
        end
      {{sender, ref}, :list} -> 
        send sender, {ref, todos}
        callLoopAgain [todos]
      {{sender, ref}, :stop} ->
        send sender, {ref, :ok}
      {{sender, ref},:update} ->
        send sender, {ref, :updated}
        callLoopAgain [todos]
      {{sender, ref},:complete, id} ->
        case _complete_item(todos, id, []) do
          {:ok, updated_todos} -> 
            send sender, {ref, :completed}
            callLoopAgain [updated_todos]
          {:error, message} ->
            send sender, {ref, :error, message}
            callLoopAgain [todos]
        end
    end
  end

  defp callLoopAgain(todos) do
    apply __MODULE__, :loop, todos
  end

  def generate_id() do
    "md5-#{:crypto.hash(:md5, to_string(:rand.uniform)) |> Base.encode16(case: :lower)}"
  end

end
