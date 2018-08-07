defmodule TodoList.Md5Hash do
  # @enforce_keys [:title, :completed]
  # defstruct [:id, :title, :completed, :created_at]
  # defstruct [:title, :completed]

  def generate(id) do
    :crypto.hash(:md5, to_string(id))
      |> Base.encode16
  end
end
