defmodule FileRead do
  def read(path), do: File.read(path)
  def exist, do: read("basic_types/lists.exs")
  def not_exists, do: read("fail")
end
