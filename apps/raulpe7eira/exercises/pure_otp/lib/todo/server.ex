defmodule TODO.Server do
  use GenServer

  ## Client API

  def start_link(opts) do
    GenServer.start_link __MODULE__, :ok, opts
  end

  def add(server, task) do
    GenServer.call server, {:add, task}
  end

  def list(server) do
    GenServer.call server, :list
  end

  def complete(server, id) do
    GenServer.call server, {:complete, id}
  end

  ## Server API

  @impl true
  def init(:ok) do
    TODO.List.start_link([])
  end

  @impl true
  def handle_call({:add, %{title: title, completed: completed}}, _from, list) do
    response = case TODO.List.create_task(list, title, completed) do
      {:ok, created_task} -> render_response {:add, created_task}
      {:error, reason} -> %{error: reason}
    end

    {:reply, response, list}
  end

  @impl true
  def handle_call(:list, _from, list) do
    tasks = TODO.List.tasks(list)
    response = render_response {:list, tasks}

    {:reply, response, list}
  end

  @impl true
  def handle_call({:complete, id}, _from, list) do
    response = case TODO.List.complete_task(list, id) do
      {:ok, completed_task} -> render_response {:complete, completed_task}
      {:error, reason} -> %{error: reason}
    end

    {:reply, response, list}
  end

  ## Response Render

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
