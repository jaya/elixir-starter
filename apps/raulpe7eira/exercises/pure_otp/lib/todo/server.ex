defmodule TODO.Server do
  use GenServer

  ## Client API

  def start_link(opts) do
    GenServer.start_link __MODULE__, :ok, opts
  end

  def add(task) do
    GenServer.call __MODULE__, {:add, task}
  end

  def list() do
    GenServer.call __MODULE__, :list
  end

  def complete(id) do
    GenServer.call __MODULE__, {:complete, id}
  end

  ## Server API

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:add, %{title: title, completed: completed}}, _from, list) do
    case created?(list, title) do
      true -> 
        {:reply, %{ error: "task already created" }, list}      
      false ->
        task = TODO.Task.create(title, completed)
        {:reply, render_response({:add, task}), Map.put(list, task.id, task)}
    end 
  end

  def handle_call(:list, _from, list) do
    {:reply, render_response({:list, Map.values(list)}), list}
  end

  def handle_call({:complete, id}, _from, list) do
    case completed?(list, id) do
      true -> 
        {:reply, %{ error: "task already completed" }, list}      
      false ->      
        {completed_task, updated_list} = Map.get_and_update(list, id, fn task ->
          updated = TODO.Task.complete(task)
          {updated, updated}
        end)
        {:reply, render_response({:complete, completed_task}), updated_list}
    end
  end

  defp created?(list, title) do
    list
    |> Map.values
    |> Enum.any?(fn task ->
      Map.fetch!(task, :title) == title
    end)
  end

  defp completed?(list, id) do
    list
    |> Map.values
    |> Enum.find(fn task ->
      Map.fetch!(task, :id) == id && Map.fetch!(task, :completed)
    end) != nil
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

  defp filter_by_keys(task, filter_keys) when is_map(task) and is_list(filter_keys) do
    task
    |> Map.from_struct
    |> Enum.filter(fn {key, _value} -> key not in filter_keys end)
    |> Enum.into(%{})
  end
end
