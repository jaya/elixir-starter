defmodule TodoList.Md5Hash do
  def generate(id) do
    :crypto.hash(:md5, to_string(id))
      |> Base.encode16
  end
end
