defmodule TODO do
  @moduledoc """
  The TODO is responsable for control a list of tasks.
  """

  alias TODO.Task

  @timeout_ms 3_000

  @doc """
  Initializes and starts receiving requests for the Tasks.
  """
  def init do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :receiving_requests, [[]] 
        Process.register pid, __MODULE__
        treat_success "TODO is started"
      pid when is_pid(pid) ->
        treat_error "TODO is already starting, shutdown first."
    end
  end

  @doc """
  Adds a new Task in the TODO.
  """
  def add(task) when is_map(task) do
    do_add task
  end

  defp do_add(%{title: title, completed: completed}) do
    send_request :add, self(), [title, completed]
  end
  defp do_add(%{completed: _completed}), do:
    treat_error "ops... title is required"
  defp do_add(%{title: _title}), do:
    treat_error "ops... completed is required"
  defp do_add(%{}), do:
    treat_error "ops... title and completed is required"

  @doc """
  Lists the created Tasks.
  """
  def list do
    send_request :list, self()
  end

  @doc """
  Completes a created Task.
  """
  def complete(id_task) do
    send_request :complete, self(), [id_task]
  end

  @doc """
  Shuts this control down, for force the supervisor the restart it.
  """
  def shutdown do
    send_request :shutdown, self()
  end

  defp send_request(action, caller) do
    send __MODULE__, {action, caller}
    receive_response action
  end
  defp send_request(action, caller, params) do
    send __MODULE__, {action, caller, params}
    receive_response action
  end

  defp receive_response(action) do
    receive do
      {:ok, value} -> render_response({action, value})
      {:error, value} -> treat_error value
    after @timeout_ms -> treat_error "ops... I forgot to #{action}"
    end
  end

  defp render_response({:add, task}) when is_map(task) do
    task
    |> filter_by_keys([:completed_at])
  end
  defp render_response({:list, todo}) when is_list(todo) do
    todo
    |> Enum.map(&(filter_by_keys(&1, [:created_at, :completed_at])))
  end
  defp render_response({:complete, task}) when is_map(task) do
    task
    |> filter_by_keys([])
  end
  defp render_response({:shutdown, message}) do
    treat_success message
  end

  defp filter_by_keys(task, filter_keys) when is_map(task) and is_list(filter_keys) do
    task
    |> Map.from_struct
    |> Enum.filter(fn {key, _value} -> key not in filter_keys end)
    |> Enum.into(%{})
  end

  defp treat_success(message) do
    %{ok: message}
  end

  defp treat_error(reason) do
    %{error: reason}
  end

  @doc """
  Receiving a request, while this control is started.
  """
  def receiving_requests(todo) when is_list(todo) do
    receive do
      {:add, caller, [title, completed]} ->
        task = Task.create todo, title, completed
        send_response caller, task
        todo = insert todo, task
        receiving_requests todo

      {:list, caller} ->
        send_response caller, todo
        receiving_requests todo

      {:complete, caller, [id_task]} ->
        task = Task.complete todo, id_task
        todo = update todo, task
        send_response caller, task
        receiving_requests todo

      {:shutdown, caller} ->
        send_response caller, "TODO shutdown"
    end
  end

  defp insert(todo, task) when is_list(todo) and is_map(task) do
    [task | todo]
  end
  defp insert(todo, _task) when is_list(todo), do: todo 

  defp update(todo, task) when is_list(todo) and is_map(task) do
    todo
    |> Enum.map(&(if &1.id == task.id, do: task, else: &1))
  end
  defp update(todo, _task) when is_list(todo), do: todo

  defp send_response(caller, {:unchecked, reason}), do: send caller, {:error, reason}
  defp send_response(caller, task) when is_map(task), do: send caller, {:ok, task}
  defp send_response(caller, todo) when is_list(todo), do: send caller, {:ok, todo}
  defp send_response(caller, message), do: send caller, {:ok, message}

end
