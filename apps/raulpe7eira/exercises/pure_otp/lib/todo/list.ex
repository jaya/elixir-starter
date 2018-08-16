defmodule TODO.List do
  use Agent

  @inicial_tasks %{}

  def start_link(_opt) do
    Agent.start_link fn ->
      @inicial_tasks
    end
  end

  def create_task(list, title, completed) do
    case created?(list, title) do
      false ->
        created_task = TODO.Task.create(title, completed)
        Agent.update list, &Map.put(&1, created_task.id, created_task)
        {:ok, created_task}
      true -> {:error, "task already created"}
    end
  end

  def tasks(list) do
    Agent.get(list, &(&1))
    |> Map.values
  end

  def complete_task(list, id) do
    case completed?(list, id) do
      false ->
        task = Agent.get list, &Map.get(&1, id)
        completed_task = TODO.Task.complete task
        Agent.update list, &Map.put(&1, task.id, completed_task)
        {:ok, completed_task}
      true -> {:error, "task already completed"}
    end
  end

  defp created?(list, title) do
    Agent.get list, fn task ->
      task
      |> Map.values
      |> Enum.any?(fn task -> task.title == title end)
    end
  end

  defp completed?(list, id) do
    Agent.get list, fn task ->
      task
      |> Map.get(id)
      |> (&(&1.completed)).()
    end
  end
end
