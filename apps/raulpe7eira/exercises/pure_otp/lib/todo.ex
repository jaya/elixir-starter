defmodule TODO do
  @moduledoc """
  """

  @enforce_keys [:title, :completed]
  defstruct [:id, :title, :completed, :created_at, :completed_at]

  @doc """
  """
  def add(item) when is_map(item) do
    do_add(item)
  end

  defp do_add(%{title: title, completed: completed}) do
    send PID_TODO, {:add, self(), title, completed}
    receive do
      todo -> render_by_action {:add, todo}
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
    send PID_TODO, {:list, self()}
    receive do
      todo_list -> render_by_action {:list, todo_list}
    after 3000 -> "ops... I forgot to list"
    end
  end

  @doc """
  """
  def complete do
    # nothing to do yet.    
  end


  @doc """
  """
  def start_link do
    init()
  end

  defp init do
    pid = spawn_link __MODULE__, :service_loop, [[]] 
    Process.register pid, PID_TODO
  end

  @doc """
  """
  def service_loop(todo_list) when is_list(todo_list) do
    receive do
      {:add, caller, title, completed} ->
        todo = %TODO{
          id: make_new_id(),
          title: title,
          completed: completed,
          created_at: get_current_date()
        }
        send caller, todo
        service_loop([todo | todo_list])

      {:list, caller} ->
        send caller, todo_list
        service_loop(todo_list)

      {:complete, _caller} ->
        service_loop(todo_list)
    end
  end

  defp make_new_id do
    utc_now = NaiveDateTime.utc_now()
    |> NaiveDateTime.to_string

    "md5-#{
      :crypto.hash(:md5, utc_now)
      |> Base.encode16
      |> String.downcase
    }"
  end

  defp get_current_date do
    Date.utc_today()
    |> Date.to_string
  end

  defp render_by_action({:add, struct}) when is_map(struct) do
    struct
    |> filter_by_keys([:completed_at])
  end
  defp render_by_action({:list, todo_list}) when is_list(todo_list) do
    todo_list
    |> Enum.map(&(&1 |> filter_by_keys([:created_at, :completed_at])))
  end

  defp filter_by_keys(map, filter_keys) when is_map(map) and is_list(filter_keys) do
    map
    |> Map.from_struct
    |> Enum.filter(fn {key, _value} -> key not in filter_keys end)
    |> Enum.into(%{})
  end
end
