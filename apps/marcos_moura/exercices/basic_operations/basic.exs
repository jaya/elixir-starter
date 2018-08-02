defmodule Basic do
  def list_concat, do: [1, 2, 3] ++ [4, 5, 6]
  def list_sub, do: [1, 2, 3] -- [2]

  def concat(p1, p2), do: p1 <> p2
  def hello, do: concat("hello ", "world")
end
