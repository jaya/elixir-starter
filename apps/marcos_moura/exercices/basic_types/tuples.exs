defmodule Test do
  def tuple, do: {:ok, "hello"}
  def first, do: elem(tuple, 0)
  def second, do: elem(tuple, 1)
  def size, do: tuple_size(tuple)
  def add(item), do: put_elem(tuple, 1, item)
end
