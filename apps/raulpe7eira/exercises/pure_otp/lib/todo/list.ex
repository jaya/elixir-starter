defmodule TODO.List do
  use Agent

  @inicial_tasks %{}

  def start_link(_opt) do
    Agent.start_link fn ->
      @inicial_tasks
    end
  end

  def create_task(list, title, completed) do
    Agent.get_and_update list, fn tasks ->
      task = Enum.find(Map.values(tasks), &(&1.title == title))
      if task != nil do
        {{:error, "task already created"}, tasks}
      else
        created_task = TODO.Task.create title, completed
        {{:ok, created_task}, Map.put(tasks, created_task.id, created_task)}
      end
    end
  end

  def tasks(list) do
    Agent.get(list, &(&1))
    |> Map.values
  end

  def complete_task(list, id) do
    Agent.get_and_update list, fn tasks ->
      task = Map.get tasks, id
      if task.completed  do
        {{:error, "task already completed"}, tasks}
      else
        completed_task = TODO.Task.complete task
        {{:ok, completed_task}, Map.put(tasks, id, completed_task)}
      end
    end
  end
end
