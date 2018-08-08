defmodule TODO.Item do
  @moduledoc """
  """

  alias TODO.Item

  @doc """
  """
  @enforce_keys [:title, :completed]
  defstruct [:id, :title, :completed, :created_at, :completed_at]

  @doc """
  """
  def new(title, completed) do
    %Item{
      id: new_id(),
      title: title,
      completed: completed,
      created_at: get_current_date()
    }
  end

  @doc """
  """
  def complete(todo_list, id) when is_list(todo_list) do
    item = todo_list
    |> Enum.map(&(Map.from_struct(&1)))
    |> Enum.find(&(id == Map.fetch!(&1, :id)))
    |> Map.update!(:completed, &(!&1))
    |> Map.update!(:completed_at, &(&1 = get_current_date()))

    struct(Item, item)
  end

  defp new_id do
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
end
