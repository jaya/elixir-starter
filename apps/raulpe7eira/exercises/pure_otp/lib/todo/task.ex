defmodule TODO.Task do
  @moduledoc """
  """

  alias TODO.Task

  @doc """
  """
  @enforce_keys [:title, :completed]
  defstruct [:id, :title, :completed, :created_at, :completed_at]

  @doc """
  """
  def create(todo, title, completed) do
    if is_created(todo, title) do
      treat_unchecked "task already created"
    else
      %Task{
        id: create_id(),
        title: title,
        completed: completed,
        created_at: get_current_date()
      }
    end
  end

  defp is_created(todo, title) do
    Enum.any?(todo, &(title == Map.fetch!(&1, :title)))
  end

  defp create_id do
    utc_now = NaiveDateTime.utc_now()
    |> NaiveDateTime.to_string

    "md5-#{
      :crypto.hash(:md5, utc_now)
      |> Base.encode16
      |> String.downcase
    }"
  end

  @doc """
  """
  def complete(todo, id) when is_list(todo) do
    if is_completed(todo, id) do
      treat_unchecked "task already completed"
    else
      struct(Task, todo
        |> Enum.map(&(Map.from_struct(&1)))
        |> Enum.find(&(id == Map.fetch!(&1, :id)))
        |> Map.update!(:completed, &(!&1))
        |> Map.update!(:completed_at, &(&1 = get_current_date()))
      )
    end
  end

  defp is_completed(todo, id) do
    todo
    |> Enum.map(&(Map.from_struct(&1)))
    |> Enum.find(&(id == Map.fetch!(&1, :id) && Map.fetch!(&1, :completed)))
  end

  defp get_current_date do
    Date.utc_today()
    |> Date.to_string
  end

  defp treat_unchecked(reason) do
    {:unchecked, reason}
  end
end
