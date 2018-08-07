defmodule TodoList.Repository do
  # @enforce_keys [:title, :completed]
  # defstruct [:id, :title, :completed, :created_at]
  # defstruct [:title, :completed]

  def build(todo, id) do
    alias TodoList.Md5Hash

    Map.put(todo, :id, Md5Hash.generate(id))
      |> Map.put(:created_at, to_string(Date.utc_today))
  end

  def complete(id, list) do
    Enum.map list, fn todo ->
                     if todo.id == id do
                       %{todo | completed: true}
                     else
                       todo
                     end
                   end
  end

  def find(id, list) do
    Enum.find list, fn todo -> todo.id == id end
  end
end

