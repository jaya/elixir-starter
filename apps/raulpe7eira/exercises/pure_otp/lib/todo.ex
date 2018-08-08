defmodule TODO_Supervisor do
  def start_link do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :init, []
        Process.register pid, __MODULE__
        IO.puts "~> TODO_Supervisor is started."
      pid when is_pid(pid) ->
        IO.puts "TODO_Supervisor is already starting."
    end
  end

  def init do
    Process.flag :trap_exit, true
    TODO.init()
    supervising_todo()
  end

  def supervising_todo do
    receive do
      {:EXIT, _from, _reason} ->
        IO.puts "~> TODO Supervisor: TODO ops..."
        TODO.init()
        IO.puts "~> TODO Supervisor: TODO restarted."
        supervising_todo()
    end
  end
end

defmodule TODO_Item do
  @enforce_keys [:title, :completed]
  defstruct [:id, :title, :completed, :created_at, :completed_at]
end

defmodule TODO do
  @moduledoc """
  """

  @timeout_ms 3_000

  @doc """
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
  """
  def add(item) when is_map(item) do
    do_add item
  end

  defp do_add(%{title: title, completed: completed}) do
    is_not_created_task(title, fn _response ->
      send_request :add, self(), [title, completed]
    end)
  end
  defp do_add(%{completed: _completed}), do:
    treat_error "ops... title is required"
  defp do_add(%{title: _title}), do:
    treat_error "ops... completed is required"
  defp do_add(%{}), do:
    treat_error "ops... title and completed is required"

  defp is_not_created_task(title, callback) do
    send_request :check_created, self(), [title], callback
  end

  @doc """
  """
  def list do
    send_request :list, self()
  end

  @doc """
  """
  def complete(id_item) do
    is_not_completed_task(id_item, fn _response ->
      send_request :complete, self(), [id_item]
    end)
  end

  defp is_not_completed_task(id_item, callback) do
    send_request :check_completed, self(), [id_item], callback
  end

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
  defp send_request(action, caller, params, callback) do
    send __MODULE__, {action, caller, params}
    receive_response action, callback
  end

  defp receive_response(action) do
    receive_response action, &render_response/1
  end
  defp receive_response(action, callback) do
    receive do
      {:ok, value} -> callback.({action, value})
      {:error, value} -> treat_error value
    after @timeout_ms -> treat_error "ops... I forgot to #{action}"
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
  defp render_response({:shutdown, message}) do
    treat_success message
  end

  defp filter_by_keys(todo_item, filter_keys) when is_map(todo_item) and is_list(filter_keys) do
    todo_item
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
  """
  def receiving_requests(todo_list) when is_list(todo_list) do
    receive do
      {:add, caller, [title, completed]} ->
        todo_item = make_new_todo_item title, completed
        send_response caller, todo_item
        receiving_requests [todo_item | todo_list]

      {:list, caller} ->
        send_response caller, todo_list
        receiving_requests todo_list

      {:complete, caller, [id_item]} ->
        todo_item = complete_todo_item todo_list, id_item
        todo_list = update_todo_list todo_list, todo_item
        send_response caller, todo_item
        receiving_requests todo_list

      {:check_created, caller, [title]} ->
        created_task = check_created_task todo_list, title
        send_response caller, created_task
        receiving_requests todo_list

      {:check_completed, caller, [id_item]} ->
        completed_task = check_completed_task todo_list, id_item
        send_response caller, completed_task
        receiving_requests todo_list

      {:shutdown, caller} ->
        send_response caller, "TODO shutdown"
    end
  end

  defp make_new_todo_item(title, completed) do
    %TODO_Item{
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

    struct(TODO_Item, todo_item)
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

    if (created_task), do: {true, "task already created"}, else: {false}
  end

  defp check_completed_task(todo_list, id_item) do
    completed_task = todo_list
    |> Enum.map(&(Map.from_struct(&1)))
    |> Enum.find(&(id_item == Map.fetch!(&1, :id) && Map.fetch!(&1, :completed)))

    if (completed_task), do: {true, "task already completed"}, else: {false}
  end

  defp send_response(caller, todo_item) when is_map(todo_item), do: send caller, {:ok, todo_item}
  defp send_response(caller, todo_list) when is_list(todo_list), do: send caller, {:ok, todo_list}
  defp send_response(caller, {true, reason}), do: send caller, {:error, reason}
  defp send_response(caller, {false}), do: send caller, {:ok, false}
  defp send_response(caller, message), do: send caller, {:ok, message}

end
