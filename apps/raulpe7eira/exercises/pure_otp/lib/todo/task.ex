defmodule TODO.Task do
  # to use agent here too.

  defstruct [
    :id,
    :title,
    :completed,
    :created_at,
    :completed_at
  ]

  def create(title, completed) do
    %__MODULE__{
      id: create_id(),
      title: title,
      completed: completed,
      created_at: get_current_date()
    }
  end

  def complete(task) do
    task
    |> Map.put(:completed, true)
    |> Map.put(:completed_at, get_current_date())
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

  defp get_current_date do
    Date.utc_today()
    |> Date.to_string
  end
end
