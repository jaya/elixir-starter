defmodule TODO do
  @moduledoc """
  """

  @enforce_keys [
    :title,
    :completed
  ]
  defstruct [
    :id,
    :title,
    :completed,
    :created_at,
    :completed_at
  ]

  @doc """
  """
  def add(item) when is_map(item) do
    do_add(item)
  end

  defp do_add(%{title: title, completed: completed}) do
    send PID_TODO, {:add, self(), title, completed}
    receive do
      todo -> filter_nil_value todo
    after 5 -> "ops... I don't no know where I am"
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
    # nothing to do yet.
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

      {:list, _caller} ->
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

  defp filter_nil_value(struct) when is_map(struct) do
    struct
    |> Map.from_struct
    |> Enum.filter(fn {_key, value} -> value != nil end)
    |> Enum.into(%{})
  end
end
