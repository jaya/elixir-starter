defmodule TODO_ITEM do
  @enforce_keys [:title, :completed]
  defstruct [:id, :title, :completed, :created_at, :completed_at]
end

defmodule TODO do
  @moduledoc """
  """

  @doc """
  """
  def add(item) when is_map(item) do
    do_add(item)
  end

  defp do_add(%{title: title, completed: completed}) do
    send TODO_PID, {:add, self(), title, completed}
    receive do
      todo_item -> render_by_action {:add, todo_item}
    after 3000 -> "ops... I forgot to add"
    end
  end
  defp do_add(%{completed: _completed}), do:
    "ops... title is required"
  defp do_add(%{title: _title}), do:
    "ops... completed is required"
  defp do_add(%{}), do:
    "ops... title and completed is required"

  @doc """
  """
  def list do
    send TODO_PID, {:list, self()}
    receive do
      todo_list -> render_by_action {:list, todo_list}
    after 3000 -> "ops... I forgot to list"
    end
  end

  @doc """
  """
  def complete(id_item) do
    send TODO_PID, {:complete, self(), id_item}
    receive do
      todo_item -> render_by_action {:complete, todo_item}
    after 3000 -> "ops... I forgot to complete"
    end
  end

  @doc """
  """
  def start_link do
    init()
  end

  defp init do
    pid = spawn_link __MODULE__, :service_loop, [[]] 
    Process.register pid, TODO_PID
  end

  @doc """
  """
  def service_loop(todo_list) when is_list(todo_list) do
    receive do
      {:add, caller, title, completed} ->
        todo_item = make_new_todo_item(title, completed)
        send caller, todo_item
        service_loop([todo_item | todo_list])

      {:list, caller} ->
        send caller, todo_list
        service_loop(todo_list)

      {:complete, caller, id_item} ->
        todo_item = complete_todo_item(todo_list, id_item)
        todo_list = update_todo_list(todo_list, todo_item)
        send caller, todo_item
        service_loop(todo_list)
    end
  end

  defp make_new_todo_item(title, completed) do
    %TODO_ITEM{
      id: make_new_id_item(),
      title: title,
      completed: completed,
      created_at: get_current_date()
    }
  end

  defp make_new_id_item do
    utc_now = NaiveDateTime.utc_now()
    |> NaiveDateTime.to_string

    "md5-#{
      :crypto.hash(:md5, utc_now)
      |> Base.encode16
      |> String.downcase
    }"
  end

  defp complete_todo_item(todo_list, id_item) when is_list(todo_list) do
    todo_item = todo_list
    |> Enum.map(&(Map.from_struct(&1)))
    |> Enum.find(&(id_item == Map.fetch!(&1, :id)))
    |> Map.update!(:completed, &(!&1))
    |> Map.update!(:completed_at, &(&1 = get_current_date()))

    struct(TODO_ITEM, todo_item)
  end

  defp update_todo_list(todo_list, todo_item) when is_list(todo_list) do
    teste = todo_list
    |> Enum.map(&(if &1.id == todo_item.id, do: &1 = todo_item, else: &1))
  end

  defp get_current_date do
    Date.utc_today()
    |> Date.to_string
  end

  defp render_by_action({:add, todo_item}) when is_map(todo_item) do
    todo_item
    |> filter_by_keys([:completed_at])
  end
  defp render_by_action({:list, todo_list}) when is_list(todo_list) do
    todo_list
    |> Enum.map(&(&1 |> filter_by_keys([:created_at, :completed_at])))
  end
  defp render_by_action({:complete, todo_item}) when is_map(todo_item) do
    todo_item
    |> filter_by_keys([])
  end

  defp filter_by_keys(todo_item, filter_keys) when is_map(todo_item) and is_list(filter_keys) do
    todo_item
    |> Map.from_struct
    |> Enum.filter(fn {key, _value} -> key not in filter_keys end)
    |> Enum.into(%{})
  end
end
