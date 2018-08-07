defmodule TODO_ITEM do
  @enforce_keys [:title, :completed]
  defstruct [:id, :title, :completed, :created_at, :completed_at]
end

defmodule TODO do
  @moduledoc """
  """

  @doc """
  """
  def start_link do
    init()
  end

  defp init do
    pid = spawn_link __MODULE__, :receiving_requests, [[]] 
    Process.register pid, TODO_PID
  end

  @doc """
  """
  def add(item) when is_map(item) do
    do_add(item)
  end

  defp do_add(%{title: title, completed: completed}) do
    is_not_created_task(title, fn _response ->
      send_request(:add, self(), [title, completed])
    end)
  end
  defp do_add(%{completed: _completed}), do:
    "ops... title is required"
  defp do_add(%{title: _title}), do:
    "ops... completed is required"
  defp do_add(%{}), do:
    "ops... title and completed is required"

  defp is_not_created_task(title, callback) do
    send_request(:check_created, self(), [title], callback)
  end

  @doc """
  """
  def list do
    send_request(:list, self())
  end

  @doc """
  """
  def complete(id_item) do
    is_not_completed_task(id_item, fn _response ->
      send_request(:complete, self(), [id_item])
    end)
  end

  defp is_not_completed_task(id_item, callback) do
    send_request(:check_completed, self(), [id_item], callback)
  end

  defp send_request(action, caller) do
    send TODO_PID, {action, caller}
    receive_response(action)
  end
  defp send_request(action, caller, params) do
    send TODO_PID, {action, caller, params}
    receive_response(action)
  end
  defp send_request(action, caller, params, callback) do
    send TODO_PID, {action, caller, params}
    receive_response(action, callback)
  end

  defp receive_response(action) do
    receive_response(action, &render_response/1)
  end
  defp receive_response(action, callback) do
    receive do
      {:ok, value} -> callback.({action, value})
      {:error, value} -> treat_error(value)
    after 3000 -> "ops... I forgot to #{action}"
    end
  end

  defp render_response({:add, todo_item}) when is_map(todo_item) do
    todo_item
    |> filter_by_keys([:completed_at])
  end
  defp render_response({:list, todo_list}) when is_list(todo_list) do
    todo_list
    |> Enum.map(&(filter_by_keys(&1, [:created_at, :completed_at])))
  end
  defp render_response({:complete, todo_item}) when is_map(todo_item) do
    todo_item
    |> filter_by_keys([])
  end

  defp filter_by_keys(todo_item, filter_keys) when is_map(todo_item) and is_list(filter_keys) do
    todo_item
    |> Map.from_struct
    |> Enum.filter(fn {key, _value} -> key not in filter_keys end)
    |> Enum.into(%{})
  end

  defp treat_error(reason) do
    %{error: reason}
  end

  @doc """
  """
  def receiving_requests(todo_list) when is_list(todo_list) do
    receive do
      {:add, caller, [title, completed]} ->
        todo_item = make_new_todo_item(title, completed)
        send_response caller, todo_item
        receiving_requests([todo_item | todo_list])

      {:list, caller} ->
        send_response caller, todo_list
        receiving_requests(todo_list)

      {:complete, caller, [id_item]} ->
        todo_item = complete_todo_item(todo_list, id_item)
        todo_list = update_todo_list(todo_list, todo_item)
        send_response caller, todo_item
        receiving_requests(todo_list)

      {:check_created, caller, [title]} ->
        created_task = check_created_task(todo_list, title)
        send_response caller, created_task
        receiving_requests(todo_list)

      {:check_completed, caller, [id_item]} ->
        completed_task = check_completed_task(todo_list, id_item)
        send_response caller, completed_task
        receiving_requests(todo_list)
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
    todo_list
    |> Enum.map(&(if &1.id == todo_item.id, do: todo_item, else: &1))
  end

  defp get_current_date do
    Date.utc_today()
    |> Date.to_string
  end

  defp check_created_task(todo_list, title) do
    created_task = todo_list
    |> Enum.any?(&(title == Map.fetch!(&1, :title)))

    if (created_task), do: "task already created", else: false
  end

  defp check_completed_task(todo_list, id_item) do
    completed_task = todo_list
    |> Enum.map(&(Map.from_struct(&1)))
    |> Enum.find(&(id_item == Map.fetch!(&1, :id) && Map.fetch!(&1, :completed)))

    if (completed_task), do: "task already completed", else: false
  end

  defp send_response(caller, todo_item) when is_map(todo_item), do: send caller, {:ok, todo_item}
  defp send_response(caller, todo_list) when is_list(todo_list), do: send caller, {:ok, todo_list}
  defp send_response(caller, not_check) when is_boolean(not_check), do: send caller, {:ok, not_check}
  defp send_response(caller, reason_check), do: send caller, {:error, reason_check}

end
