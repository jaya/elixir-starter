defmodule ConcatList do
  def list, do: [104, 101, 108, 108, 111]

  def hd_add(item), do: item ++ list
  def tl_add(item), do: list ++ item
end
