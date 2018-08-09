defmodule TodoList.Repository do
  @doc """
  Build a todo with ID and created_at
  """
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

  @doc """
  Find an item by his ID
  """
  def find(id, todos) do
    Enum.find todos, fn todo -> todo.id == id end
  end

  @doc """
  An item is valid when
    * there is not other item with the same title
  """
  def valid?(todo, list) do
    !Enum.any?(list, fn x -> x.title == todo.title end)
  end

  @doc """
  Check if an item is already completed
  """
  def completed?(id, list) do
    find(id, list)
      |> is_complete?
  end

  #TODO, reponde with a different erro message when is nill
  defp is_complete?(nil), do: true
  defp is_complete?(todo), do: todo.completed == true
end

